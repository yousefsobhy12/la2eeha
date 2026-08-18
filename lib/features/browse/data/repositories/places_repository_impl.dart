import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasource/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlacesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories() {
    // CategoryModel هو أصلاً Category (extends)، فمفيش تحويل زيادة مطلوب
    return remoteDataSource.getCategories();
  }

  @override
  Future<List<Place>> getMostVisitedPreview() {
    return remoteDataSource.getMostVisitedPreview();
  }

  @override
  Future<List<Place>> getAllPlacesPreview() {
    return remoteDataSource.getAllPlacesPreview();
  }
}