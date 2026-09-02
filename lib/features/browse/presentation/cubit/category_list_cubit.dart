// lib/features/browse/presentation/cubit/category_list_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import 'category_list_state.dart';

class CategoryListCubit extends Cubit<CategoryListState> {
  final PlacesRepository repository;
  final int? categoryId; // null = "all places" mode

  static const int pageSize = 20;
  int _offset = 0;

  CategoryListCubit(this.repository, {this.categoryId})
      : super(const CategoryListLoading());

  Future<void> loadInitial() async {
    emit(const CategoryListLoading());
    _offset = 0;

    final results = await Future.wait([
      repository.getCategories(),
      repository.getAreas(),
      repository.getCategoryPlaces(
        categoryId: categoryId,
        limit: pageSize,
        offset: 0,
      ),
      repository.getCategoryPlacesCount(categoryId: categoryId),
      categoryId != null
          ? repository.getSubCategories(categoryId!)
          : Future.value(const Right<Failure, List<String>>([])),
    ]);

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
      ),
    );
  }

  // IMPORTANT: a loadMore failure must NOT wipe the screen to an error state —
  // the user already has a visible list. Just stop the loading indicator.
  Future<void> loadMore() async {
    final current = state;
    if (current is! CategoryListLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final result = await repository.getCategoryPlaces(
      categoryId: categoryId,
      subCategory: current.selectedSubCategory,
      limit: pageSize,
      offset: _offset,
    );

    result.fold(
      (failure) {
        emit(current.copyWith(isLoadingMore: false));
      },
      (newPlaces) {
        _offset += newPlaces.length;
        emit(
          current.copyWith(
            places: [...current.places, ...newPlaces],
            isLoadingMore: false,
            hasMore: newPlaces.length == pageSize,
          ),
        );
      },
    );
  }

  Future<void> selectSubCategory(String? subCategory) async {
    final current = state;
    if (current is! CategoryListLoaded) return;
    if (current.selectedSubCategory == subCategory) return;

    emit(
      current.copyWith(
        places: [],
        selectedSubCategory: subCategory,
        clearSelectedSubCategory: subCategory == null,
        hasMore: true,
      ),
    );
    _offset = 0;

    final results = await Future.wait([
      repository.getCategoryPlaces(
        categoryId: categoryId,
        subCategory: subCategory,
        limit: pageSize,
        offset: 0,
      ),
      repository.getCategoryPlacesCount(
        categoryId: categoryId,
        subCategory: subCategory,
      ),
    ]);

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
        ),
      );
    }
  }

  Future<void> refresh() => loadInitial();
}
