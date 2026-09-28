// lib/features/browse/presentation/views/home_view.dart
//
// ✅ الهيدر بقى ColoredSectionHeader المشترك (نفس ستايل More View بالظبط)،
// ثابت برّه الـ BlocBuilder — يعني بيبان فورًا حتى وقت التحميل، ومش بيتغطى
// بالـ skeleton. الـ SafeArea(top: false) لأن الهيدر نفسه هو اللي بيدّي
// المساحة اللي فوق الـ status bar (زي More View بالظبط).
//
// 🔧 البادي بقى CustomScrollView + Slivers بدل SingleChildScrollView > Column —
// أحسن في الأداء (lazy building) ومفيش nested scrollables (shrinkWrap).
// الأقسام بتتبني كـ slivers: HomeSearchBar (SliverToBoxAdapter)،
// CategoryGrid (SliverGrid)، MostVisitedSection (SliverToBoxAdapter)،
// AllPlacesSection (SliverList + SliverToBoxAdapters).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../data/datasource/places_remote_datasource.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/all_places_section.dart';
import '../widgets/category_grid.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/most_visited_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
      )..loadHome(),
      child: const _HomeViewBody(),
    );
  }
}

class _HomeViewBody extends StatelessWidget {
  const _HomeViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Column(
        children: [
          const ColoredSectionHeader(
            title: 'لاقيها',
            subtitle: 'لاقي كل حاجة قريبة منك في مكان واحد',
          ),
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading || state is HomeInitial) {
                  return const HomeSkeleton();
                }

                if (state is HomeError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        state.message.toBody(
                          context,
                          color: context.textSecondary,
                        ),
                        context.smallSpacing.vSpace,
                        TextButton(
                          onPressed: () => context.read<HomeCubit>().loadHome(),
                          child: 'حاول تاني'.toBody(
                            context,
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final loaded = state as HomeLoaded;

                return RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().refresh(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: context.pagePadding,
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            // ─── Search bar ───
                            SliverPadding(
                              padding: EdgeInsets.only(top: context.vSpacing),
                              sliver: SliverToBoxAdapter(
                                child: const HomeSearchBar().fadeSlideIn(),
                              ),
                            ),

                            // ─── Categories grid ───
                            SliverPadding(
                              padding: EdgeInsets.only(
                                top: context.largeSpacing,
                              ),
                              sliver: CategoryGrid(
                                categories: loaded.categories,
                              ),
                            ),

                            // ─── Most visited carousel ───
                            SliverPadding(
                              padding: EdgeInsets.only(
                                top: context.largeSpacing,
                              ),
                              sliver: SliverToBoxAdapter(
                                child:
                                    MostVisitedSection(
                                      places: loaded.mostVisited,
                                      categoryNameOf: loaded.categoryNameOf,
                                      categoryIconOf: loaded.categoryIconOf,
                                    ).fadeSlideIn(
                                      delay: const Duration(milliseconds: 120),
                                    ),
                              ),
                            ),

                            // ─── All places section (spread slivers) ───
                            ...() {
                              final allPlacesSlivers = AllPlacesSection(
                                places: loaded.allPlacesPreview,
                                categoryNameOf: loaded.categoryNameOf,
                                categoryIconOf: loaded.categoryIconOf,
                                areaNameOf: loaded.areaNameOf,
                              ).buildSlivers(context);
                              if (allPlacesSlivers.isEmpty) {
                                return <Widget>[];
                              }
                              return <Widget>[
                                SliverPadding(
                                  padding: EdgeInsets.only(
                                    top: context.largeSpacing,
                                  ),
                                  sliver: SliverMainAxisGroup(
                                    slivers: allPlacesSlivers,
                                  ),
                                ),
                              ];
                            }(),

                            // ─── Bottom padding (floating nav bar) ───
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: context.extraLargeSpacing * 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
