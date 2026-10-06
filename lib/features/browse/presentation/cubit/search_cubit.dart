import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/search_normalizer_extension.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_filters.dart';
import '../../domain/repositories/places_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final PlacesRepository repository;
  static const int pageSize = 20;
  static const Duration debounceDuration = Duration(milliseconds: 500);
  static const int minQueryLength = 2;

  Timer? _debounce;
  int _offset = 0;
  String _currentQuery = '';
  List<int> _currentAreaIds = [];

  String _pendingNormalized = '';
  String _pendingDisplay = '';

  PlaceFilters _filters = const PlaceFilters();
  PlaceFilters get filters => _filters;

  int _searchToken = 0;

  Map<int, String>? _categoryNameById;
  Map<int, String>? _categoryIconById;
  Map<int, String>? _areaNameById;
  Map<int, String>? _normalizedAreaNameById;

  SearchCubit(this.repository) : super(const SearchInitial());

  void onQueryChanged(String query) {
    _debounce?.cancel();
    _searchToken++;
    final normalized = query.toSearchQuery();
    if (normalized.length < minQueryLength) {
      emit(SearchInitial(filters: _filters));
      return;
    }
    final display = query.trim();
    _pendingNormalized = normalized;
    _pendingDisplay = display;
    _debounce = Timer(debounceDuration, () => _search(normalized, display));
  }

  void applyFilters(PlaceFilters filters) {
    if (filters == _filters) return;
    _filters = filters;

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      _searchToken++;
      _search(_pendingNormalized, _pendingDisplay);
      return;
    }

    final current = state;
    if (current is SearchInitial || _currentQuery.length < minQueryLength) {
      emit(SearchInitial(filters: _filters));
      return;
    }

    _searchToken++;
    _debounce?.cancel();
    final display = current is SearchLoaded ? current.query : _currentQuery;
    _search(_currentQuery, display);
  }

  Future<void> _search(String normalizedQuery, String displayQuery) async {
    final token = _searchToken;
    emit(SearchLoading(filters: _filters));
    _currentQuery = normalizedQuery;
    _offset = 0;

    if (_categoryNameById == null) {
      final lookupResults = await Future.wait([
        repository.getCategories(),
        repository.getAreas(),
      ]);
      if (token != _searchToken) return;

      final categoriesEither =
          lookupResults[0] as Either<Failure, List<Category>>;
      final areasEither = lookupResults[1] as Either<Failure, List<Area>>;

      if (categoriesEither.isLeft() || areasEither.isLeft()) {
        final failure =
            categoriesEither.fold((f) => f, (_) => null) ??
            areasEither.fold((f) => f, (_) => null);
        emit(SearchError(failure as Failure, filters: _filters));
        return;
      }

      final categories = categoriesEither.getOrElse(() => []);
      final areas = areasEither.getOrElse(() => []);
      _categoryNameById = {for (final c in categories) c.id: c.nameAr};
      _categoryIconById = {for (final c in categories) c.id: c.icon};
      _areaNameById = {for (final a in areas) a.id: a.nameAr};
      _normalizedAreaNameById = {
        for (final a in areas) a.id: a.nameAr.normalizeArabic(),
      };
    }

    _currentAreaIds = _normalizedAreaNameById!.entries
        .where((entry) => entry.value.contains(normalizedQuery))
        .map((entry) => entry.key)
        .toList();

    final results = await Future.wait([
      repository.searchPlaces(
        query: normalizedQuery,
        areaIds: _currentAreaIds,
        filters: _filters,
        limit: pageSize,
        offset: 0,
      ),
      repository.getSearchResultsCount(
        query: normalizedQuery,
        areaIds: _currentAreaIds,
        filters: _filters,
      ),
    ]);
    if (token != _searchToken) return;

    final placesEither = results[0] as Either<Failure, List<Place>>;
    final countEither = results[1] as Either<Failure, int>;

    if (placesEither.isLeft() || countEither.isLeft()) {
      final failure =
          placesEither.fold((f) => f, (_) => null) ??
          countEither.fold((f) => f, (_) => null);
      emit(SearchError(failure as Failure, filters: _filters));
      return;
    }

    final places = placesEither.getOrElse(() => []);
    final count = countEither.getOrElse(() => 0);
    _offset = places.length;

    emit(
      SearchLoaded(
        query: displayQuery,
        places: places,
        categoryNameById: _categoryNameById!,
        categoryIconById: _categoryIconById!,
        areaNameById: _areaNameById!,
        totalCount: count,
        hasMore: places.length == pageSize,
        isLoadingMore: false,
        filters: _filters,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! SearchLoaded) return;
    if (current.places.isEmpty) return;
    if (!current.hasMore || current.isLoadingMore) return;

    final token = _searchToken;
    emit(current.copyWith(isLoadingMore: true, filters: _filters));

    final result = await repository.searchPlaces(
      query: _currentQuery,
      areaIds: _currentAreaIds,
      filters: _filters,
      limit: pageSize,
      offset: _offset,
    );
    if (token != _searchToken) return;

    result.fold(
      (failure) =>
          emit(current.copyWith(isLoadingMore: false, filters: _filters)),
      (newPlaces) {
        _offset += newPlaces.length;
        emit(
          current.copyWith(
            places: [...current.places, ...newPlaces],
            isLoadingMore: false,
            hasMore: newPlaces.length == pageSize,
            filters: _filters,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _searchToken++;
    _debounce?.cancel();
    return super.close();
  }
}
