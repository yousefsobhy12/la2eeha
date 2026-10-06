import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_filters.dart';
import '../../domain/repositories/places_repository.dart';
import 'category_list_state.dart';

class CategoryListCubit extends Cubit<CategoryListState> {
  final PlacesRepository repository;
  final int? categoryId;

  static const int pageSize = 20;
  int _offset = 0;
  PlaceFilters _filters = const PlaceFilters();
  PlaceFilters get filters => _filters;
  int _requestToken = 0;

  CategoryListCubit(this.repository, {this.categoryId})
    : super(const CategoryListLoading());

  int _beginRequest() => ++_requestToken;
  bool _isStale(int token) => token != _requestToken;

  Future<void> loadInitial() async {
    final token = _beginRequest();
    emit(const CategoryListLoading());
    _offset = 0;

    final results = await Future.wait([
      repository.getCategories(),
      repository.getAreas(),
      repository.getCategoryPlaces(
        categoryId: categoryId,
        filters: _filters,
        limit: pageSize,
        offset: 0,
      ),
      repository.getCategoryPlacesCount(
        categoryId: categoryId,
        filters: _filters,
      ),
      categoryId != null
          ? repository.getSubCategories(categoryId!)
          : Future.value(const Right<Failure, List<String>>([])),
    ]);

    if (_isStale(token)) return;

    final categoriesEither = results[0] as Either<Failure, List<Category>>;
    final areasEither = results[1] as Either<Failure, List<Area>>;
    final placesEither = results[2] as Either<Failure, List<Place>>;
    final countEither = results[3] as Either<Failure, int>;
    final subCategoriesEither = results[4] as Either<Failure, List<String>>;

    for (final either in [
      categoriesEither,
      areasEither,
      placesEither,
      countEither,
      subCategoriesEither,
    ]) {
      if (either.isLeft()) {
        final failure = either.fold((f) => f, (_) => null) as Failure;
        emit(CategoryListError(failure));
        return;
      }
    }

    final categories = categoriesEither.getOrElse(() => []);
    final areas = areasEither.getOrElse(() => []);
    final places = placesEither.getOrElse(() => []);
    final count = countEither.getOrElse(() => 0);
    final subCategories = subCategoriesEither.getOrElse(() => []);

    _offset = places.length;

    emit(
      CategoryListLoaded(
        places: places,
        categoryNameById: {for (final c in categories) c.id: c.nameAr},
        categoryIconById: {for (final c in categories) c.id: c.icon},
        areaNameById: {for (final a in areas) a.id: a.nameAr},
        subCategories: subCategories,
        selectedSubCategory: null,
        totalCount: count,
        hasMore: places.length == pageSize,
        isLoadingMore: false,
        filters: _filters,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! CategoryListLoaded) return;
    if (current.places.isEmpty) return;
    if (!current.hasMore || current.isLoadingMore) return;
    final token = _requestToken;

    emit(current.copyWith(isLoadingMore: true));

    final result = await repository.getCategoryPlaces(
      categoryId: categoryId,
      subCategory: current.selectedSubCategory,
      filters: _filters,
      limit: pageSize,
      offset: _offset,
    );

    if (_isStale(token)) return;

    result.fold(
      (failure) {
        emit(current.copyWith(isLoadingMore: false, filters: _filters));
      },
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

  Future<void> selectSubCategory(String? subCategory) async {
    final current = state;
    if (current is! CategoryListLoaded) return;
    if (current.selectedSubCategory == subCategory) return;

    final token = _beginRequest();

    emit(
      current.copyWith(
        places: [],
        selectedSubCategory: subCategory,
        clearSelectedSubCategory: subCategory == null,
        hasMore: true,
        isLoadingMore: false,
        isReloading: true,
        filters: _filters,
      ),
    );
    _offset = 0;

    final results = await Future.wait([
      repository.getCategoryPlaces(
        categoryId: categoryId,
        subCategory: subCategory,
        filters: _filters,
        limit: pageSize,
        offset: 0,
      ),
      repository.getCategoryPlacesCount(
        categoryId: categoryId,
        subCategory: subCategory,
        filters: _filters,
      ),
    ]);

    if (_isStale(token)) return;

    final placesEither = results[0] as Either<Failure, List<Place>>;
    final countEither = results[1] as Either<Failure, int>;

    if (placesEither.isLeft() || countEither.isLeft()) {
      final failure =
          placesEither.fold((f) => f, (_) => null) ??
          countEither.fold((f) => f, (_) => null);
      emit(CategoryListError(failure as Failure));
      return;
    }

    final places = placesEither.getOrElse(() => []);
    final count = countEither.getOrElse(() => 0);
    _offset = places.length;

    final latest = state;
    if (latest is CategoryListLoaded) {
      emit(
        latest.copyWith(
          places: places,
          totalCount: count,
          hasMore: places.length == pageSize,
          isReloading: false,
          filters: _filters,
        ),
      );
    }
  }

  Future<void> applyFilters(PlaceFilters filters) async {
    if (filters == _filters) return;

    final current = state;
    if (current is! CategoryListLoaded) {
      _filters = filters;
      return;
    }

    final token = _beginRequest();

    _filters = filters;
    _offset = 0;

    emit(
      current.copyWith(
        places: [],
        hasMore: true,
        isLoadingMore: false,
        isReloading: true,
      ),
    );

    final results = await Future.wait([
      repository.getCategoryPlaces(
        categoryId: categoryId,
        subCategory: current.selectedSubCategory,
        filters: _filters,
        limit: pageSize,
        offset: 0,
      ),
      repository.getCategoryPlacesCount(
        categoryId: categoryId,
        subCategory: current.selectedSubCategory,
        filters: _filters,
      ),
    ]);

    if (_isStale(token)) return;

    final placesEither = results[0] as Either<Failure, List<Place>>;
    final countEither = results[1] as Either<Failure, int>;

    if (placesEither.isLeft() || countEither.isLeft()) {
      final failure =
          placesEither.fold((f) => f, (_) => null) ??
          countEither.fold((f) => f, (_) => null);
      emit(CategoryListError(failure as Failure));
      return;
    }

    final places = placesEither.getOrElse(() => []);
    final count = countEither.getOrElse(() => 0);
    _offset = places.length;

    final latest = state;
    if (latest is CategoryListLoaded) {
      emit(
        latest.copyWith(
          places: places,
          totalCount: count,
          hasMore: places.length == pageSize,
          isReloading: false,
          filters: _filters,
        ),
      );
    }
  }

  Future<void> refresh() => loadInitial();
}
