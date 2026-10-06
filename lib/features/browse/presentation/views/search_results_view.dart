import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/place_card.dart';
import '../../data/datasource/places_remote_datasource.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../domain/entities/place_filters.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/place_filters_button.dart';
import '../widgets/place_filters_sheet.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(
        PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
      ),
      child: const _SearchResultsBody(),
    );
  }
}

class _SearchResultsBody extends StatefulWidget {
  const _SearchResultsBody();

  @override
  State<_SearchResultsBody> createState() => _SearchResultsBodyState();
}

class _SearchResultsBodyState extends State<_SearchResultsBody> {
  late final ScrollController _scrollController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _textController = TextEditingController()
      ..addListener(() => setState(() {}));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<SearchCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.pagePadding.horizontal / 2,
                    vertical: context.smallSpacing,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Container(
                          height: context.textFieldHeight,
                          padding: EdgeInsets.symmetric(
                            horizontal: context.hSpacing,
                          ),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: context.roundRadius.circularRadius,
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: context.textSecondary,
                              ),
                              context.smallSpacing.hSpace,
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  autofocus: true,
                                  style: TextStyle(
                                    fontSize: (14.sp * context.fontScale).clamp(
                                      12.sp,
                                      16.sp,
                                    ),
                                    color: context.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'ابحث عن اسم المكان أو العنوان...',
                                    hintStyle: TextStyle(
                                      fontSize: (14.sp * context.fontScale)
                                          .clamp(12.sp, 16.sp),
                                      color: context.hintColor,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) => context
                                      .read<SearchCubit>()
                                      .onQueryChanged(value),
                                ),
                              ),
                              if (_textController.text.isNotEmpty)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: context.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _textController.clear();
                                    context.read<SearchCubit>().onQueryChanged(
                                      '',
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      PlaceFiltersButton(
                        filters: state.filters,
                        onPressed: () {
                          final cubit = context.read<SearchCubit>();
                          PlaceFiltersSheet.show(
                            context,
                            initial: cubit.filters,
                            showDelivery: true,
                            onChanged: cubit.applyFilters,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return switch (state) {
                    SearchInitial() => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 48,
                            color: context.iconColor,
                          ),
                          context.smallSpacing.vSpace,
                          'اكتب حرفين على الأقل عشان نقدر ندور'.toBody(
                            context,
                            color: context.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    SearchLoading() => const _SearchListSkeleton(),
                    SearchError(failure: final failure) => _SearchListErrorView(
                      failure: failure,
                    ),
                    SearchLoaded() => _buildLoadedView(context, state),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, SearchLoaded state) {
    if (state.places.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: context.iconColor),
            context.smallSpacing.vSpace,
            if (state.filters.isActive)
              'مفيش نتايج لـ "${state.query}" بالفلاتر دي'.toBody(
                context,
                color: context.textSecondary,
                textAlign: TextAlign.center,
              )
            else
              'مفيش نتايج لـ "${state.query}"'.toBody(
                context,
                color: context.textSecondary,
              ),
            if (state.filters.isActive) ...[
              context.mediumSpacing.vSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.largeSpacing),
                child: CustomElevatedButton(
                  text: 'مسح الفلاتر',
                  onPressed: () => context.read<SearchCubit>().applyFilters(
                    const PlaceFilters(),
                  ),
                  isOutlined: true,
                  backgroundColor: context.colorScheme.primary,
                  height: 48,
                  fontSize: 14,
                  borderRadius: 12,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: context.pagePadding.horizontal / 2,
            vertical: context.smallSpacing,
          ),
          sliver: SliverToBoxAdapter(
            child: '${state.totalCount} نتيجة'.toCaption(
              context,
              color: context.textSecondary,
            ),
          ),
        ),
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
        if (state.isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: context.mediumSpacing.verticalPadding,
              child: const Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: context.largeSpacing)),
      ],
    );
  }
}

class _SearchListSkeleton extends StatelessWidget {
  const _SearchListSkeleton();

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

class _SearchListErrorView extends StatelessWidget {
  final Failure failure;
  const _SearchListErrorView({required this.failure});

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
        ],
      ).fadeSlideIn(),
    );
  }
}
