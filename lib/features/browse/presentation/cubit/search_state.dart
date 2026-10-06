import '../../../../core/errors/failures.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_filters.dart';

sealed class SearchState {
  final PlaceFilters filters;

  const SearchState({this.filters = const PlaceFilters()});
}

class SearchInitial extends SearchState {
  const SearchInitial({super.filters});
}

class SearchLoading extends SearchState {
  const SearchLoading({super.filters});
}

class SearchLoaded extends SearchState {
  final String query;
  final List<Place> places;
  final Map<int, String> categoryNameById;
  final Map<int, String> categoryIconById;
  final Map<int, String> areaNameById;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;

  const SearchLoaded({
    required this.query,
    required this.places,
    required this.categoryNameById,
    required this.categoryIconById,
    required this.areaNameById,
    required this.totalCount,
    required this.hasMore,
    required this.isLoadingMore,
    super.filters,
  });

  String categoryNameOf(int? categoryId) => categoryNameById[categoryId] ?? '';
  String categoryIconOf(int? categoryId) => categoryIconById[categoryId] ?? '';
  String? areaNameOf(int? areaId) => areaNameById[areaId];

  SearchLoaded copyWith({
    List<Place>? places,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    PlaceFilters? filters,
  }) {
    return SearchLoaded(
      query: query,
      places: places ?? this.places,
      categoryNameById: categoryNameById,
      categoryIconById: categoryIconById,
      areaNameById: areaNameById,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
    );
  }
}

class SearchError extends SearchState {
  final Failure failure;
  const SearchError(this.failure, {super.filters});
  String get message => failure.message;
}
