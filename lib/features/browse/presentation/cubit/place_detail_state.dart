import '../../../../core/errors/failures.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/sports_pricing.dart';

sealed class PlaceDetailState {
  const PlaceDetailState();
}

class PlaceDetailLoading extends PlaceDetailState {
  const PlaceDetailLoading();
}

class PlaceDetailLoaded extends PlaceDetailState {
  final Place place;
  final String categoryName;
  final String categoryIcon;
  final String? areaName;
  final List<MenuItem>? menuItems;
  final List<SportsPricing>? sportsPricing;
  final List<Place> similarPlaces;
  final List<Branch> branches;

  const PlaceDetailLoaded({
    required this.place,
    required this.categoryName,
    required this.categoryIcon,
    this.areaName,
    this.menuItems,
    this.sportsPricing,
    this.similarPlaces = const [],
    this.branches = const [],
  });
}

class PlaceDetailError extends PlaceDetailState {
  final Failure failure;
  const PlaceDetailError(this.failure);
  String get message => failure.message;
}
