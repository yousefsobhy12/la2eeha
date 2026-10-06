import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/repositories/places_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final PlacesRepository repository;

  static const int mostVisitedLimit = 10;

  HomeCubit(this.repository) : super(const HomeInitial());

  Future<void> loadHome() async {
    emit(const HomeLoading());

    final results = await Future.wait([
      repository.getCategories(),
      repository.getMostVisitedPreview(limit: mostVisitedLimit),
      repository.getLivePromotions(),
      repository.getAreas(),
    ]);

    final categoriesEither = results[0] as Either<Failure, List<Category>>;
    final mostVisitedEither = results[1] as Either<Failure, List<Place>>;
    final promotionsEither = results[2] as Either<Failure, List<Promotion>>;
    final areasEither = results[3] as Either<Failure, List<Area>>;

    for (final either in [categoriesEither, mostVisitedEither, areasEither]) {
      if (either.isLeft()) {
        final failure = either.fold((f) => f, (_) => null) as Failure;
        emit(HomeError(failure));
        return;
      }
    }

    final categories = categoriesEither.getOrElse(() => []);
    final mostVisited = mostVisitedEither.getOrElse(() => []);
    final promotions = promotionsEither.getOrElse(() => const []);
    final areas = areasEither.getOrElse(() => []);

    emit(
      HomeLoaded(
        categories: categories,
        mostVisited: mostVisited,
        promotions: promotions,
        categoryNameById: {for (final c in categories) c.id: c.nameAr},
        categoryIconById: {for (final c in categories) c.id: c.icon},
        areaNameById: {for (final a in areas) a.id: a.nameAr},
      ),
    );
  }

  Future<void> refresh() => loadHome();
}
