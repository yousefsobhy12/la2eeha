import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/place_pricing_helpers.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/colored_section_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/datasource/merchant_remote_datasource.dart';
import '../../data/repositories/merchant_repository_impl.dart';
import '../../domain/entities/my_place_item.dart';
import '../cubit/my_place_status.dart';
import '../cubit/my_places_cubit.dart';
import '../cubit/my_places_state.dart';
import 'pricing_args.dart';

class MyPlacesView extends StatelessWidget {
  const MyPlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyPlacesCubit(
        MerchantRepositoryImpl(remoteDataSource: MerchantRemoteDataSource()),
      )..load(),
      child: const _MyPlacesBody(),
    );
  }
}

class _MyPlacesBody extends StatelessWidget {
  const _MyPlacesBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Column(
        children: [
          ColoredSectionHeader(
            title: 'أعمالي',
            subtitle: 'تابع حالة أماكنك وعدّل أسعارك',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: context.colorScheme.onPrimary,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
            ),
          ),
          Expanded(
            child: BlocBuilder<MyPlacesCubit, MyPlacesState>(
              builder: (context, state) {
                if (state is MyPlacesInitial || state is MyPlacesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MyPlacesError) {
                  return _buildErrorView(context, state);
                }
                final loaded = state as MyPlacesLoaded;
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<MyPlacesCubit>().load(silent: true),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      if (loaded.places.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: true,
                          child: Center(
                            child: Padding(
                              padding: context.pagePadding,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.storefront_outlined,
                                    size: 48,
                                    color: context.iconColor,
                                  ),
                                  context.smallSpacing.vSpace,
                                  'لسه مضفتش أي مكان'.toBody(
                                    context,
                                    color: context.textSecondary,
                                    textAlign: TextAlign.center,
                                  ),
                                  context.mediumSpacing.vSpace,
                                  _buildAddButton(context),
                                ],
                              ),
                            ),
                          ),
                        )
                      else ...[
                        SliverPadding(
                          padding: context.pagePadding.copyWith(
                            top: context.mediumSpacing,
                          ),
                          sliver: SliverList.separated(
                            itemCount: loaded.places.length,
                            separatorBuilder: (context, index) =>
                                context.smallSpacing.vSpace,
                            itemBuilder: (context, index) => _MyPlaceCard(
                              item: loaded.places[index],
                            ).fadeSlideIn(delay: AppAnimations.stagger(index)),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: context.pagePadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                context.largeSpacing.vSpace,
                                _buildAddButton(context),
                                context.extraLargeSpacing.vSpace,
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildErrorView(BuildContext context, MyPlacesError state) {
    return Center(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: context.iconColor),
            context.smallSpacing.vSpace,
            state.message.toBody(
              context,
              color: context.textSecondary,
              textAlign: TextAlign.center,
            ),
            context.smallSpacing.vSpace,
            ElevatedButton(
              onPressed: () => context.read<MyPlacesCubit>().load(),
              child: 'حاول تاني'.toBody(
                context,
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return CustomElevatedButton(
      text: 'إضافة مكان جديد',
      onPressed: () async {
        final cubit = context.read<MyPlacesCubit>();
        await context.push('/add-place');
        if (!cubit.isClosed) cubit.load(silent: true);
      },
      backgroundColor: AppColors.primary,
      textColor: AppColors.onPrimary,
      height: context.buttonHeight,
      fontWeight: FontWeight.bold,
      borderRadius: context.largeRadius,
      boxShadow: const [
        BoxShadow(
          color: AppColors.primaryPressedShadow,
          offset: Offset(0, 3),
          blurRadius: 0,
        ),
      ],
    );
  }
}

class _MyPlaceCard extends StatelessWidget {
  const _MyPlaceCard({required this.item});

  final MyPlaceItem item;

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final screenType = pricingScreenTypeFor(
      categoryId: item.categoryId,
      subCategory: item.subCategory,
    );
    final showPricing =
        status != MyPlaceStatus.rejected &&
        screenType != PlacePricingScreenType.none;

    return Container(
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.mediumRadius.circularRadius,
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: item.name.toTitle(
                  context,
                  maxLines: 1,
                  textAlign: item.name.isMostlyArabic
                      ? TextAlign.right
                      : TextAlign.left,
                ),
              ),
              _StatusPill(status: status),
            ],
          ),
          if (status == MyPlaceStatus.pending) ...[
            context.smallSpacing.vSpace,
            Text(
              'بيزنسك قيد المراجعة — هنراجع البيانات ونوافق عليه في أقرب وقت',
              style: TextStyle(
                fontSize: ResponsiveValues.bodyLarge(context),
                color: context.textSecondary,
              ),
            ),
          ],
          if (status == MyPlaceStatus.rejected) ...[
            context.smallSpacing.vSpace,
            Container(
              padding: 12.allPadding,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: context.mediumRadius.circularRadius,
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'سبب الرفض',
                    style: TextStyle(
                      fontSize: ResponsiveValues.bodyLarge(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  6.vSpace,
                  Text(
                    item.rejectionReason!,
                    style: TextStyle(
                      fontSize: ResponsiveValues.bodyLarge(context),
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item.hasPendingPricing) ...[
            context.smallSpacing.vSpace,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.smallSpacing,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: context.roundRadius.circularRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_top_rounded,
                    size: context.smallIconSize,
                    color: context.colorScheme.primary,
                  ),
                  6.hSpace,
                  'فيه تعديلات أسعار قيد المراجعة'.toCaption(
                    context,
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
          if (showPricing) ...[
            8.vSpace,
            _buildPricingButton(context, screenType),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingButton(
    BuildContext context,
    PlacePricingScreenType screenType,
  ) {
    final label = screenType == PlacePricingScreenType.sportsPricing
        ? 'تعديل أسعار الساعة'
        : 'تعديل ${pricingLabelsFor(categoryId: item.categoryId, subCategory: item.subCategory).screenTitle}';

    return CustomElevatedButton(
      text: label,
      isOutlined: true,
      backgroundColor: context.colorScheme.primary,
      height: context.buttonHeight,
      borderRadius: context.largeRadius,
      onPressed: () async {
        final cubit = context.read<MyPlacesCubit>();
        final args = PricingArgs(
          placeId: item.id,
          placeName: item.name,
          categoryId: item.categoryId,
          subCategory: item.subCategory,
        );
        await context.push(
          screenType == PlacePricingScreenType.sportsPricing
              ? '/place/${item.id}/pricing'
              : '/place/${item.id}/menu',
          extra: args,
        );
        if (!cubit.isClosed) cubit.load(silent: true);
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final MyPlaceStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      MyPlaceStatus.approved => (
        context.isDarkMode ? const Color(0xFF6FCF83) : const Color(0xFF2F6B3A),
        Icons.check_circle_rounded,
        'مقبول',
      ),
      MyPlaceStatus.pending => (
        context.colorScheme.primary,
        Icons.hourglass_empty_rounded,
        'قيد المراجعة',
      ),
      MyPlaceStatus.rejected => (
        Colors.redAccent,
        Icons.cancel_rounded,
        'مرفوض',
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.smallSpacing,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: context.roundRadius.circularRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.smallIconSize, color: color),
          4.hSpace,
          label.toCaption(context, color: color, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
