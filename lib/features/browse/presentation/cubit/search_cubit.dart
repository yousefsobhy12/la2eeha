// lib/features/browse/presentation/cubit/search_cubit.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';
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

  // Cached once on the first successful search, reused for every subsequent
  // query so we don't re-fetch categories/areas on every keystroke — and also
  // used to match area names locally (no extra Supabase query for that).
  Map<int, String>? _categoryNameById;
  Map<int, String>? _categoryIconById;
  Map<int, String>? _areaNameById;

  SearchCubit(this.repository) : super(const SearchInitial());

  void onQueryChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < minQueryLength) {
      emit(const SearchInitial());
      return;
    }
    _debounce = Timer(debounceDuration, () => _search(trimmed));
  }

  Future<void> _search(String query) async {
    emit(const SearchLoading());
    _currentQuery = query;
    _offset = 0;

    // لو أول مرة نبحث في السيشن دي، نجيب categories/areas الأول ونخزنهم —
    // لازم يحصل ده الأول عشان نقدر نطابق اسم المنطقة locally قبل ما نبحث.
    if (_categoryNameById == null) {
      final lookupResults = await Future.wait([
        repository.getCategories(),
        repository.getAreas(),
      ]);

      final categoriesEither =
          lookupResults[0] as Either<Failure, List<Category>>;
      final areasEither = lookupResults[1] as Either<Failure, List<Area>>;

      if (categoriesEither.isLeft() || areasEither.isLeft()) {
        final failure =
            categoriesEither.fold((f) => f, (_) => null) ??
            areasEither.fold((f) => f, (_) => null);
        emit(SearchError(failure as Failure));
        return;
      }

      final categories = categoriesEither.getOrElse(() => []);
      final areas = areasEither.getOrElse(() => []);
      _categoryNameById = {for (final c in categories) c.id: c.nameAr};
      _categoryIconById = {for (final c in categories) c.id: c.icon};
      _areaNameById = {for (final a in areas) a.id: a.nameAr};
    }

    // مطابقة اسم المنطقة محليًا من الكاش الموجود عندنا أصلاً — مفيش أي
    // Supabase query إضافية هنا خالص.
    _currentAreaIds = _areaNameById!.entries
        .where((entry) => entry.value.contains(query))
        .map((entry) => entry.key)
        .toList();

    final results = await Future.wait([
      repository.searchPlaces(
        query: query,
        areaIds: _currentAreaIds,
        limit: pageSize,
        offset: 0,
      ),
      repository.getSearchResultsCount(query: query, areaIds: _currentAreaIds),
    ]);

    final placesEither = results[0] as Either<Failure, List<Place>>;
    final countEither = results[1] as Either<Failure, int>;

    if (placesEither.isLeft() || countEither.isLeft()) {
      final failure =
          placesEither.fold((f) => f, (_) => null) ??
          countEither.fold((f) => f, (_) => null);
      emit(SearchError(failure as Failure));
      return;
    }

    final places = placesEither.getOrElse(() => []);
    final count = countEither.getOrElse(() => 0);
    _offset = places.length;

    emit(
      SearchLoaded(
        query: query,
        places: places,
        categoryNameById: _categoryNameById!,
        categoryIconById: _categoryIconById!,
        areaNameById: _areaNameById!,
        totalCount: count,
        hasMore: places.length == pageSize,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! SearchLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final result = await repository.searchPlaces(
      query: _currentQuery,
      areaIds: _currentAreaIds,
      limit: pageSize,
      offset: _offset,
    );

    result.fold((failure) => emit(current.copyWith(isLoadingMore: false)), (
      newPlaces,
    ) {
      _offset += newPlaces.length;
      emit(
        current.copyWith(
          places: [...current.places, ...newPlaces],
          isLoadingMore: false,
          hasMore: newPlaces.length == pageSize,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
