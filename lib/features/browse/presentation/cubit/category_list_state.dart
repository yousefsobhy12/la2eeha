import '../../../../core/errors/failures.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_filters.dart';

sealed class CategoryListState {
  const CategoryListState();
}

class CategoryListLoading extends CategoryListState {
  const CategoryListLoading();
}

class CategoryListLoaded extends CategoryListState {
  final List<Place> places;
  final Map<int, String> categoryNameById;
  final Map<int, String> categoryIconById;
  final Map<int, String> areaNameById;
  final List<String> subCategories;
  final String? selectedSubCategory;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isReloading;
  final PlaceFilters filters;

  const CategoryListLoaded({
    required this.places,
    required this.categoryNameById,
    required this.categoryIconById,
    required this.areaNameById,
    required this.subCategories,
    required this.selectedSubCategory,
    required this.totalCount,
    required this.hasMore,
    required this.isLoadingMore,
    this.filters = const PlaceFilters(),
    this.isReloading = false,
  });

  String categoryNameOf(int? categoryId) => categoryNameById[categoryId] ?? '';
  String categoryIconOf(int? categoryId) => categoryIconById[categoryId] ?? '';
  String? areaNameOf(int? areaId) => areaNameById[areaId];

  CategoryListLoaded copyWith({
    List<Place>? places,
    List<String>? subCategories,
    String? selectedSubCategory,
    bool clearSelectedSubCategory = false,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    PlaceFilters? filters,
    bool? isReloading,
  }) {
    return CategoryListLoaded(
      places: places ?? this.places,
      categoryNameById: categoryNameById,
      categoryIconById: categoryIconById,
      areaNameById: areaNameById,
      subCategories: subCategories ?? this.subCategories,
      selectedSubCategory: clearSelectedSubCategory
          ? null
          : (selectedSubCategory ?? this.selectedSubCategory),
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
      isReloading: isReloading ?? this.isReloading,
    );
  }
}

class CategoryListError extends CategoryListState {
  final Failure failure;
  const CategoryListError(this.failure);
  String get message => failure.message;
}
