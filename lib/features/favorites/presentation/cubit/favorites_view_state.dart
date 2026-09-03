import 'package:la2eeha/core/errors/failures.dart';
import 'package:la2eeha/features/browse/domain/entities/place.dart';

sealed class FavoritesViewState {
  const FavoritesViewState();
}

class FavoritesViewLoading extends FavoritesViewState {
  const FavoritesViewLoading();
}

class FavoritesViewError extends FavoritesViewState {
  final Failure failure;
  const FavoritesViewError({required this.failure});
}

class FavoritesViewLoaded extends FavoritesViewState {
  final List<Place> places;
  final Map<int, String> categoryNameOf;
  final Map<int, String> categoryIconOf;
  final Map<int, String> areaNameOf;

  const FavoritesViewLoaded({
    required this.places,
    required this.categoryNameOf,
    required this.categoryIconOf,
    required this.areaNameOf,
  });
}
