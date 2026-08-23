import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasource/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlacesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return Left(const NetworkFailure());
    } catch (_) {
      return Left(const UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Area>>> getAreas() async {
    try {
      final areas = await remoteDataSource.getAreas();
      return Right(areas);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return Left(const NetworkFailure());
    } catch (_) {
      return Left(const UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getMostVisitedPreview({int limit = 10}) async {
    try {
      final places = await remoteDataSource.getMostVisitedPreview(limit: limit);
      return Right(places);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return Left(const NetworkFailure());
    } catch (_) {
      return Left(const UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getAllPlacesPreview({int limit = 10}) async {
    try {
      final places = await remoteDataSource.getAllPlacesPreview(limit: limit);
      return Right(places);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return Left(const NetworkFailure());
    } catch (_) {
      return Left(const UnexpectedFailure());
    }
  }
}