import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:la2eeha/features/browse/data/datasource/places_remote_datasource.dart';
import 'package:la2eeha/features/browse/data/repositories/places_repository_impl.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../../../core/widgets/place_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_view_cubit.dart';
import '../cubit/favorites_view_state.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesViewCubit(
        PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
        context.read<FavoritesCubit>().state,
      )..loadFavorites(),
      child: const _FavoritesBody(),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: BlocBuilder<FavoritesViewCubit, FavoritesViewState>(
        builder: (context, state) {
          return Column(
            children: [
              const ColoredSectionHeader(
                title: 'المفضلة',
                subtitle: 'الأماكن اللي حفظتها',
              ),
              Expanded(
                child: switch (state) {
                  FavoritesViewLoading() => const _FavoritesSkeleton(),
                  FavoritesViewError(failure: final failure) =>
                    _FavoritesErrorView(failure: failure),
                  FavoritesViewLoaded() => _buildLoadedView(context, state),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, FavoritesViewLoaded state) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        if (state.places.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 48,
                    color: context.iconColor,
                  ),
                  context.smallSpacing.vSpace,
                  Text(
                    'لسه مفيش أماكن في المفضلة',
                    style: TextStyle(
                      fontSize: (14.sp * context.fontScale).clamp(12.sp, 16.sp),
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: context.pagePadding,
            sliver: SliverList.builder(
              itemCount: state.places.length,
              itemBuilder: (context, index) {
                final place = state.places[index];
                return Padding(
                  padding: EdgeInsets.only(
                    top: context.smallSpacing,
                    bottom: context.smallSpacing,
                  ),
                  child:
                      PlaceCard(
                        place: place,
                        categoryName:
                            state.categoryNameOf[place.categoryId] ?? '',
                        categoryIcon:
                            state.categoryIconOf[place.categoryId] ?? '',
                        areaName: state.areaNameOf[place.areaId] ?? '',
                        isFavorite: true,
                        onFavoriteToggle: () {
                          context.read<FavoritesCubit>().toggleFavorite(
                            place.id,
                          );
                          context.read<FavoritesViewCubit>().removeFromView(
                            place.id,
                          );
                        },
                        onTap: () => context.push('/place/${place.id}'),
                      ).fadeSlideIn(
                        delay: AppAnimations.stagger(
                          index % 10,
                          base: const Duration(milliseconds: 60),
                        ),
                      ),
                );
              },
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: context.largeSpacing)),
      ],
    );
  }
}

class _FavoritesSkeleton extends StatelessWidget {
  const _FavoritesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: context.pagePadding.copyWith(top: context.mediumSpacing),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: context.mediumSpacing),
        child: Container(
          width: double.infinity,
          height: context.skeletonPlaceCardHeight,
          decoration: BoxDecoration(
            color: context.borderColor,
            borderRadius: context.mediumRadius.circularRadius,
          ),
        ),
      ),
    ).shimmerLoop();
  }
}

class _FavoritesErrorView extends StatelessWidget {
  final Failure failure;
  const _FavoritesErrorView({required this.failure});

  @override
  Widget build(BuildContext context) {
    final IconData errorIcon;
    if (failure is NetworkFailure) {
      errorIcon = Icons.wifi_off_rounded;
    } else if (failure is ServerFailure) {
      errorIcon = Icons.cloud_off_rounded;
    } else {
      errorIcon = Icons.error_outline_rounded;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(errorIcon, size: 48, color: context.iconColor),
          context.smallSpacing.vSpace,
          failure.message.toBody(
            context,
            color: context.textSecondary,
            textAlign: TextAlign.center,
          ),
          context.smallSpacing.vSpace,
          ElevatedButton(
            onPressed: () => context.read<FavoritesViewCubit>().loadFavorites(),
            child: 'حاول تاني'.toBody(
              context,
              color: context.colorScheme.primary,
            ),
          ),
        ],
      ).fadeSlideIn(),
    );
  }
}
