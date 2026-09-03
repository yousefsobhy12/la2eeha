// lib/features/browse/presentation/views/category_list_view.dart
//
// شاشة عرض الأماكن حسب الكاتيجوري (أو كل الأماكن لما categoryId = null).
// بتدعم الفلترة بـ sub-categories والـ pagination بـ infinite scroll.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_visuals.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../../../core/widgets/place_card.dart';
import '../../data/datasource/places_remote_datasource.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../cubit/category_list_cubit.dart';
import '../cubit/category_list_state.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../widgets/sub_category_chips.dart';

class CategoryListView extends StatelessWidget {
  final int? categoryId;
  const CategoryListView({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryListCubit(
        PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
        categoryId: categoryId,
      )..loadInitial(),
      child: _CategoryListBody(categoryId: categoryId),
    );
  }
}

class _CategoryListBody extends StatefulWidget {
  final int? categoryId;
  const _CategoryListBody({this.categoryId});

  @override
  State<_CategoryListBody> createState() => _CategoryListBodyState();
}

class _CategoryListBodyState extends State<_CategoryListBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<CategoryListCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: BlocBuilder<CategoryListCubit, CategoryListState>(
        builder: (context, state) {
          final String title;
          final String subtitle;
          final Color? headerBgColor;

          if (state is CategoryListLoaded) {
            title = widget.categoryId == null
                ? 'كل الأماكن'
                : state.categoryNameOf(widget.categoryId);
            subtitle =
                '${state.totalCount} مكان في شبين القناطر والقرى المجاورة';
            headerBgColor = widget.categoryId == null
                ? null
                : CategoryVisuals.of(
                    state.categoryIconOf(widget.categoryId),
                  ).color;
          } else {
            title = widget.categoryId == null ? 'كل الأماكن' : 'الأماكن';
            subtitle = 'شبين القناطر والقرى المجاورة';
            headerBgColor = null;
          }

          return Column(
            children: [
              ColoredSectionHeader(
                title: title,
                subtitle: subtitle,
                backgroundColor: headerBgColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  color: context.colorScheme.onPrimary,
                  onPressed: () => context.pop(),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.search_rounded),
                  color: context.colorScheme.onPrimary,
                  onPressed: () => showComingSoon(context),
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: switch (state) {
                    CategoryListLoading() => const _CategoryListSkeleton(),
                    CategoryListError(failure: final failure) =>
                      _CategoryListErrorView(failure: failure),
                    CategoryListLoaded() => _buildLoadedView(context, state),
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, CategoryListLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<CategoryListCubit>().refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ─── Sub-category chips (if available) ───
          if (state.subCategories.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.only(
                top: context.mediumSpacing,
                bottom: context.smallSpacing,
              ),
              sliver: SliverToBoxAdapter(
                child: SubCategoryChips(
                  subCategories: state.subCategories,
                  selected: state.selectedSubCategory,
                  onSelect: (value) => context
                      .read<CategoryListCubit>()
                      .selectSubCategory(value),
                ),
              ),
            ),

          // ─── Places list or empty state ───
          if (state.places.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: context.iconColor,
                    ),
                    context.smallSpacing.vSpace,
                    Text(
                      'مفيش أماكن في القسم ده حاليًا',
                      style: TextStyle(
                        fontSize: (14.sp * context.fontScale).clamp(
                          12.sp,
                          16.sp,
                        ),
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
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
                          categoryName: state.categoryNameOf(place.categoryId),
                          categoryIcon: state.categoryIconOf(place.categoryId),
                          areaName: state.areaNameOf(place.areaId),
                          isFavorite: context
                              .watch<FavoritesCubit>()
                              .state
                              .contains(place.id),
                          onFavoriteToggle: () => context
                              .read<FavoritesCubit>()
                              .toggleFavorite(place.id),
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

            // ─── Loading more indicator ───
            if (state.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.mediumSpacing.verticalPadding,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),

            // ─── Bottom spacing ───
            SliverToBoxAdapter(child: SizedBox(height: context.largeSpacing)),
          ],
        ],
      ),
    );
  }
}

class _CategoryListSkeleton extends StatelessWidget {
  const _CategoryListSkeleton();

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

class _CategoryListErrorView extends StatelessWidget {
  final Failure failure;
  const _CategoryListErrorView({required this.failure});

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
            onPressed: () => context.read<CategoryListCubit>().loadInitial(),
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
