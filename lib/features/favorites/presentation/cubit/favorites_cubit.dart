import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:la2eeha/core/storage/local_storage_service.dart';

class FavoritesCubit extends Cubit<Set<int>> {
  FavoritesCubit(this._storage) : super(<int>{}) {
    _loadSavedFavorites();
  }

  final LocalStorageService _storage;
  static const _prefsKey = 'favorite_place_ids';

  Future<void> _loadSavedFavorites() async {
    final saved = await _storage.getStringSet(_prefsKey);
    emit(saved.map(int.parse).toSet());
  }

  Future<void> toggleFavorite(int placeId) async {
    final updated = Set<int>.from(state);
    if (updated.contains(placeId)) {
      updated.remove(placeId);
    } else {
      updated.add(placeId);
    }
    emit(updated);
    await _storage.setStringSet(
      _prefsKey,
      updated.map((e) => e.toString()).toSet(),
    );
  }

  bool isFavorite(int placeId) => state.contains(placeId);
}
