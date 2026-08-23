// @lib/features/browse/presentation/cubit/home_cubit.dart
//
// 🔧 بعد ما نضيف core/errors/، الـ PlacesRepository methods بترجع
// Either<Failure, List<T>> بدل Future<List<T>> عادي. Either بيبقى إما:
//   - Left(failure)   → فشل، وبيبقى معانا نوع الـ Failure بالظبط
//   - Right(data)      → نجح، وبيبقى معانا الداتا
// .fold((failure) => ..., (data) => ...) هي الطريقة اللي بنستخرج بيها القيمة
// من جوه الـ Either، بتاخد دالتين: واحدة لو فشل وواحدة لو نجح.
//
// 🔧 لسه مفترض إن getMostVisitedPreview/getAllPlacesPreview بياخدوا named
// parameter اسمه limit — لو مختلف عندك ظبط الاستدعاء بس.

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final PlacesRepository repository;

  static const int mostVisitedLimit = 8;
  static const int allPlacesPreviewLimit = 6;

  HomeCubit(this.repository) : super(const HomeInitial());

  Future<void> loadHome() async {
    emit(const HomeLoading());

    final results = await Future.wait([
      repository.getCategories(),
      repository.getMostVisitedPreview(limit: mostVisitedLimit),
      repository.getAllPlacesPreview(limit: allPlacesPreviewLimit),
      repository.getAreas(),
    ]);

    final categoriesEither = results[0] as Either<Failure, List<Category>>;
    final mostVisitedEither = results[1] as Either<Failure, List<Place>>;
    final allPlacesEither = results[2] as Either<Failure, List<Place>>;
    final areasEither = results[3] as Either<Failure, List<Area>>;

    // لو أي واحدة من الأربعة فشلت، نوقف ونعرض أول Failure لقيناه —
    // مفيش داعي نكمل نجهز شاشة بنص بيانات ناقصة
    for (final either in [
      categoriesEither,
      mostVisitedEither,
      allPlacesEither,
      areasEither,
    ]) {
      if (either.isLeft()) {
        final failure = either.fold((f) => f, (_) => null) as Failure;
        emit(HomeError(failure));
        return;
      }
    }

    final categories = categoriesEither.getOrElse(() => []);
    final mostVisited = mostVisitedEither.getOrElse(() => []);
    final allPlacesPreview = allPlacesEither.getOrElse(() => []);
    final areas = areasEither.getOrElse(() => []);

    emit(
      HomeLoaded(
        categories: categories,
        mostVisited: mostVisited,
        allPlacesPreview: allPlacesPreview,
        categoryNameById: {for (final c in categories) c.id: c.nameAr},
        categoryIconById: {for (final c in categories) c.id: c.icon},
        areaNameById: {for (final a in areas) a.id: a.nameAr},
      ),
    );
  }

  Future<void> refresh() => loadHome();
}
