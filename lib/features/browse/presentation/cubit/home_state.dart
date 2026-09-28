// lib/features/browse/presentation/cubit/home_state.dart

import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Category> categories;
  final List<Place> mostVisited;
  final List<Place> allPlacesPreview;
  final Map<int, String> categoryNameById;
  final Map<int, String> categoryIconById;
  final Map<int, String> areaNameById;

  const HomeLoaded({
    required this.categories,
    required this.mostVisited,
    required this.allPlacesPreview,
    required this.categoryNameById,
    required this.categoryIconById,
    required this.areaNameById,
  });

  String categoryNameOf(int? categoryId) => categoryNameById[categoryId] ?? '';

  String categoryIconOf(int? categoryId) => categoryIconById[categoryId] ?? '';

  String? areaNameOf(int? areaId) => areaNameById[areaId];
}

class HomeError extends HomeState {
  final Failure failure;
  const HomeError(this.failure);

  String get message => failure.message;
}
