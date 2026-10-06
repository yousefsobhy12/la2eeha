import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la2eeha/features/browse/domain/repositories/places_repository.dart';
import 'favorites_view_state.dart';

class FavoritesViewCubit extends Cubit<FavoritesViewState> {
  FavoritesViewCubit(this._repository, this.favoriteIds)
    : super(const FavoritesViewLoading());

  final PlacesRepository _repository;
  Set<int> favoriteIds;

  Future<void> loadFavorites() async {
    if (favoriteIds.isEmpty) {
      emit(
        const FavoritesViewLoaded(
          places: [],
          categoryNameOf: {},
          categoryIconOf: {},
          areaNameOf: {},
        ),
      );
      return;
    }

    emit(const FavoritesViewLoading());

    final results = await Future.wait([
      _repository.getPlacesByIds(favoriteIds.toList()),
      _repository.getCategories(),
      _repository.getAreas(),
    ]);

    final placesEither = results[0] as dynamic;
    final categoriesEither = results[1] as dynamic;
    final areasEither = results[2] as dynamic;

    placesEither.fold((failure) => emit(FavoritesViewError(failure: failure)), (
      places,
    ) {
      final categoryNameOf = <int, String>{};
      final categoryIconOf = <int, String>{};
      final areaNameOf = <int, String>{};

      categoriesEither.fold((failure) {}, (categories) {
        for (final cat in categories) {
          categoryNameOf[cat.id] = cat.nameAr;
          categoryIconOf[cat.id] = cat.icon;
        }
      });

      areasEither.fold((failure) {}, (areas) {
        for (final area in areas) {
          areaNameOf[area.id] = area.nameAr;
        }
      });

      emit(
        FavoritesViewLoaded(
          places: places,
          categoryNameOf: categoryNameOf,
          categoryIconOf: categoryIconOf,
          areaNameOf: areaNameOf,
        ),
      );
    });
  }

  void removeFromView(int placeId) {
    if (state is FavoritesViewLoaded) {
      final currentState = state as FavoritesViewLoaded;
      final updatedPlaces = currentState.places
          .where((p) => p.id != placeId)
          .toList();

      emit(
        FavoritesViewLoaded(
          places: updatedPlaces,
          categoryNameOf: currentState.categoryNameOf,
          categoryIconOf: currentState.categoryIconOf,
          areaNameOf: currentState.areaNameOf,
        ),
      );
    }
  }

  Future<void> syncWithFavoriteIds(Set<int> newIds) async {
    if (setEquals(favoriteIds, newIds)) return;

    final current = state;

    if (current is! FavoritesViewLoaded) {
      favoriteIds = newIds;
      return;
    }

    final currentIds = current.places.map((p) => p.id).toSet();
    final addedIds = newIds.difference(currentIds);
    final removedIds = currentIds.difference(newIds);

    favoriteIds = newIds;

    var updatedPlaces = current.places;

    if (removedIds.isNotEmpty) {
      updatedPlaces = updatedPlaces
          .where((p) => !removedIds.contains(p.id))
          .toList();
    }

    if (addedIds.isNotEmpty) {
      final result = await _repository.getPlacesByIds(addedIds.toList());
      result.fold(
        (failure) {},
        (newPlaces) => updatedPlaces = [...updatedPlaces, ...newPlaces],
      );
    }

    emit(
      FavoritesViewLoaded(
        places: updatedPlaces,
        categoryNameOf: current.categoryNameOf,
        categoryIconOf: current.categoryIconOf,
        areaNameOf: current.areaNameOf,
      ),
    );
  }
}
