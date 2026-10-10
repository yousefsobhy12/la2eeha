import '../../../../core/errors/failures.dart';
import '../../domain/entities/my_place_item.dart';

abstract class MyPlacesState {
  const MyPlacesState();
}

class MyPlacesInitial extends MyPlacesState {
  const MyPlacesInitial();
}

class MyPlacesLoading extends MyPlacesState {
  const MyPlacesLoading();
}

class MyPlacesLoaded extends MyPlacesState {
  final List<MyPlaceItem> places;

  const MyPlacesLoaded(this.places);
}

class MyPlacesError extends MyPlacesState {
  final Failure failure;
  const MyPlacesError(this.failure);

  String get message => failure.message;
}
