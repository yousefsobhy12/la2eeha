// lib/features/browse/presentation/cubit/search_cubit.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/search_normalizer_extension.dart';
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
  // The NORMALIZED query (same normalization as the DB's search_text) — this
  // is what gets sent to the repository. The text shown to the user is kept
  // separately (SearchLoaded.query) and stays exactly what they typed.
  String _currentQuery = '';
  List<int> _currentAreaIds = [];

  // Incremented on every keystroke and on close(). A running _search() or
  // loadMore() compares the token it started with after each await and drops
  // its result if it changed — so a slow, outdated request can never overwrite
  // a newer state (e.g. results popping up after the user cleared the field).
  int _searchToken = 0;

  // Cached once on the first successful search, reused for every subsequent
  // query so we don't re-fetch categories/areas on every keystroke — and also
  // used to match area names locally (no extra Supabase query for that).
  Map<int, String>? _categoryNameById;
  Map<int, String>? _categoryIconById;
  Map<int, String>? _areaNameById; // original names, for display
  Map<int, String>? _normalizedAreaNameById; // normalized, for matching

  SearchCubit(this.repository) : super(const SearchInitial());

  void onQueryChanged(String query) {
    _debounce?.cancel();
    _searchToken++;
    final normalized = query.toSearchQuery();
    if (normalized.length < minQueryLength) {
      emit(const SearchInitial());
      return;
    }
    final display = query.trim();
    _debounce = Timer(debounceDuration, () => _search(normalized, display));
  }

  Future<void> _search(String normalizedQuery, String displayQuery) async {
    final token = _searchToken;
    emit(const SearchLoading());
    _currentQuery = normalizedQuery;
    _offset = 0;

    // لو أول مرة نبحث في السيشن دي، نجيب categories/areas الأول ونخزنهم —
    // لازم يحصل ده الأول عشان نقدر نطابق اسم المنطقة locally قبل ما نبحث.
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
        emit(SearchError(failure as Failure));
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

    // مطابقة اسم المنطقة محليًا من الكاش الموجود عندنا أصلاً (على الأسماء
    // المُطبَّعة) — مفيش أي Supabase query إضافية هنا خالص.
    _currentAreaIds = _normalizedAreaNameById!.entries
        .where((entry) => entry.value.contains(normalizedQuery))
        .map((entry) => entry.key)
        .toList();

    final results = await Future.wait([
      repository.searchPlaces(
        query: normalizedQuery,
        areaIds: _currentAreaIds,
        limit: pageSize,
        offset: 0,
      ),
      repository.getSearchResultsCount(
        query: normalizedQuery,
        areaIds: _currentAreaIds,
      ),
    ]);
    if (token != _searchToken) return;

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
        query: displayQuery,
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

    final token = _searchToken;
    emit(current.copyWith(isLoadingMore: true));

    final result = await repository.searchPlaces(
      query: _currentQuery,
      areaIds: _currentAreaIds,
      limit: pageSize,
      offset: _offset,
    );
    if (token != _searchToken) return;

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
    _searchToken++;
    _debounce?.cancel();
    return super.close();
  }
}