import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/category_visuals.dart';
import '../../../../core/constants/sub_category_visuals.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../data/datasource/places_remote_datasource.dart';
import '../../data/repositories/places_repository_impl.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_open_status.dart';
import '../cubit/place_detail_cubit.dart';
import '../cubit/place_detail_state.dart';
import '../widgets/place_open_status_pill.dart';
import '../widgets/pricing_card.dart';
import '../widgets/similar_places_section.dart';

class PlaceDetailView extends StatelessWidget {
  final int placeId;

  const PlaceDetailView({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlaceDetailCubit(
        PlacesRepositoryImpl(remoteDataSource: PlacesRemoteDataSource()),
        placeId: placeId,
      )..loadPlaceDetails(),
      child: const _PlaceDetailBody(),
    );
  }
}

class _PlaceDetailBody extends StatelessWidget {
  const _PlaceDetailBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        top: false,
        child: BlocBuilder<PlaceDetailCubit, PlaceDetailState>(
          builder: (context, state) {
            return switch (state) {
              PlaceDetailLoading() => const _PlaceDetailSkeleton(),
              PlaceDetailError(failure: final failure) => _PlaceDetailErrorView(
                failure: failure,
              ),
              PlaceDetailLoaded() => _buildLoadedView(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, PlaceDetailLoaded state) {
    final place = state.place;
    final visual = CategoryVisuals.of(state.categoryIcon);
    final subLabel = SubCategoryVisuals.labelOf(
      place.subCategory,
      fallback: state.categoryName,
    );

    int animIndex = 0;

    return RefreshIndicator(
      onRefresh: () => context.read<PlaceDetailCubit>().refresh(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ─── Sliver Header: Cover Image + Top Buttons ───
          SliverToBoxAdapter(child: _buildCoverHeader(context, place, visual)),

          // ─── Content Body ───
          SliverPadding(
            padding: context.pagePadding.copyWith(top: context.mediumSpacing),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Category badge + Open/Closed status pill
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: visual.color.withValues(alpha: 0.12),
                        borderRadius: context.roundRadius.circularRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            visual.icon,
                            size: context.smallIconSize,
                            color: visual.color,
                          ),
                          6.hSpace,
                          subLabel.toCaption(
                            context,
                            color: visual.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    if (place.openStatus != null) ...[
                      8.hSpace,
                      PlaceOpenStatusPill(status: place.openStatus),
                    ],
                  ],
                ).fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),

                context.smallSpacing.vSpace,

                // 2. Place name (LTR/RTL text alignment)
                place.name
                    .toHeadline(
                      context,
                      textAlign: place.name.isMostlyArabic
                          ? TextAlign.right
                          : TextAlign.left,
                    )
                    .fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),

                // 3. Area name & Working hours subtitle (if present)
                if ((state.areaName != null && state.areaName!.isNotEmpty) ||
                    (place.openTime != null && place.closeTime != null)) ...[
                  6.vSpace,
                  Row(
                    children: [
                      if (state.areaName != null &&
                          state.areaName!.isNotEmpty) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: context.smallIconSize,
                          color: context.textSecondary,
                        ),
                        4.hSpace,
                        state.areaName!.toBody(
                          context,
                          color: context.textSecondary,
                        ),
                      ],
                      if ((state.areaName != null &&
                              state.areaName!.isNotEmpty) &&
                          (place.openTime != null &&
                              place.closeTime != null)) ...[
                        8.hSpace,
                        Text(
                          '•',
                          style: TextStyle(color: context.textSecondary),
                        ),
                        8.hSpace,
                      ],
                      if (place.openTime != null &&
                          place.closeTime != null) ...[
                        Icon(
                          Icons.access_time_rounded,
                          size: context.smallIconSize,
                          color: context.textSecondary,
                        ),
                        4.hSpace,
                        '${place.openTime!.toArabicTime()} – ${place.closeTime!.toArabicTime()}'
                            .toBody(context, color: context.textSecondary),
                      ],
                    ],
                  ).fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),
                ],

                context.largeSpacing.vSpace,

                // 4. Contact Actions Row (اتصال / الموقع / واتساب)
                _buildContactActions(
                  context,
                  place,
                ).fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),

                context.largeSpacing.vSpace,

                // 5. Info List (Phone / Address / Working Hours)
                _buildInfoList(
                  context,
                  place,
                ).fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),

                // 6. Description (if present)
                if (place.description != null &&
                    place.description!.isNotEmpty) ...[
                  context.largeSpacing.vSpace,
                  _buildDescriptionCard(
                    context,
                    place.description!,
                  ).fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),
                ],

                // 7. Pricing Section (if present)
                if ((state.sportsPricing != null &&
                        state.sportsPricing!.isNotEmpty) ||
                    (state.menuItems != null &&
                        state.menuItems!.isNotEmpty)) ...[
                  context.largeSpacing.vSpace,
                  PricingCard(
                    sportsPricing: state.sportsPricing,
                    menuItems: state.menuItems,
                  ).fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),
                ],

                // 8. Similar Places (if non-empty)
                if (state.similarPlaces.isNotEmpty) ...[
                  context.largeSpacing.vSpace,
                  SimilarPlacesSection(
                    places: state.similarPlaces,
                    categoryName: state.categoryName,
                    categoryIcon: state.categoryIcon,
                    areaName: state.areaName,
                  ).fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),
                ],

                context.largeSpacing.vSpace,

                // 9. Footer Disclaimer Text
                Center(
                  child:
                      'البيانات مسجّلة من صاحب المكان. لو فيه حاجة غلط اضغط علامة التبليغ فوق.'
                          .toCaption(
                            context,
                            color: context.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                ).fadeSlideIn(delay: AppAnimations.stagger(animIndex++)),

                context.largeSpacing.vSpace,
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverHeader(
    BuildContext context,
    Place place,
    CategoryVisual visual,
  ) {
    final double headerHeight = 220.h;

    return Stack(
      children: [
        // Cover Image or Gradient Fallback
        Container(
          width: double.infinity,
          height: headerHeight,
          decoration: BoxDecoration(
            gradient: place.imageUrl != null && place.imageUrl!.isNotEmpty
                ? null
                : LinearGradient(
                    colors: [
                      visual.color.withValues(alpha: 0.35),
                      visual.color.withValues(alpha: 0.12),
                    ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
            image: place.imageUrl != null && place.imageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(place.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: place.imageUrl == null || place.imageUrl!.isEmpty
              ? Center(
                  child: Icon(visual.icon, size: 64.r, color: visual.color),
                )
              : null,
        ),

        // Dark gradient overlay for top controls visibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 90.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.50),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Top Overlay Buttons: Back & Report
        PositionedDirectional(
          top: MediaQuery.of(context).padding.top + 8.h,
          start: context.hSpacing,
          child: _HeaderCircleButton(
            icon: Icons.arrow_forward_ios_rounded,
            onPressed: () => context.pop(),
          ),
        ),
        PositionedDirectional(
          top: MediaQuery.of(context).padding.top + 8.h,
          end: context.hSpacing,
          child: _HeaderCircleButton(
            icon: Icons.flag_outlined,
            onPressed: () => showComingSoon(context),
          ),
        ),
      ],
    );
  }

  Widget _buildContactActions(BuildContext context, Place place) {
    final hasWhatsapp = place.whatsapp != null && place.whatsapp!.isNotEmpty;
    final hasMaps =
        place.googleMapsUrl != null && place.googleMapsUrl!.isNotEmpty;

    return Row(
      children: [
        // Call button (always available if phone is present)
        Expanded(
          child: _ActionButton(
            icon: Icons.phone_rounded,
            label: 'اتصال',
            color: context.colorScheme.primary,
            onPressed: () => _call(place.phone),
          ),
        ),

        // Google Maps button (if present)
        if (hasMaps) ...[
          context.smallSpacing.hSpace,
          Expanded(
            child: _ActionButton(
              icon: Icons.location_on_rounded,
              label: 'الموقع',
              color: const Color(0xFF1F6F63),
              onPressed: () => _openMaps(place.googleMapsUrl!),
            ),
          ),
        ],

        // WhatsApp button (if present)
        if (hasWhatsapp) ...[
          context.smallSpacing.hSpace,
          Expanded(
            child: _ActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'واتساب',
              color: const Color(0xFF2F6B3A),
              onPressed: () => _openWhatsApp(place.whatsapp!),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoList(BuildContext context, Place place) {
    final hasAddress = place.address.isNotEmpty;
    // Strict source: only openTime and closeTime, never legacy working_hours
    final hasWorkingHours = place.openTime != null && place.closeTime != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: context.mediumRadius.circularRadius,
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: context.cardPadding,
      child: Column(
        children: [
          // Phone row
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'التليفون',
            value: place.phone,
            onTap: () => _call(place.phone),
          ),

          // Address row (if present)
          if (hasAddress) ...[
            Divider(color: context.borderColor, height: 16.h),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'العنوان',
              value: place.address,
              isAddress: true,
            ),
          ],

          // Working hours row (if both openTime and closeTime exist)
          if (hasWorkingHours) ...[
            Divider(color: context.borderColor, height: 16.h),
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: 'مواعيد العمل',
              value:
                  '${place.openTime!.toArabicTime()} – ${place.closeTime!.toArabicTime()}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, String description) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: context.mediumRadius.circularRadius,
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: context.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'عن المكان'.toTitle(context, fontWeight: FontWeight.bold),
          8.vSpace,
          Text(
            description,
            textAlign: description.isMostlyArabic
                ? TextAlign.right
                : TextAlign.left,
            style: TextStyle(
              fontSize: (14.sp * context.fontScale).clamp(12.sp, 16.sp),
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final phoneNum = phone.replaceAll(RegExp(r'\D'), '');
    final fullNum = phoneNum.startsWith('20')
        ? phoneNum
        : (phoneNum.startsWith('0') ? '2$phoneNum' : '20$phoneNum');
    final uri = Uri.parse('https://wa.me/$fullNum');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderCircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: context.mediumIconSize),
        onPressed: onPressed,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: context.mediumRadius.circularRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: context.mediumRadius.circularRadius,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: context.smallIconSize, color: color),
              6.hSpace,
              label.toCaption(
                context,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isAddress;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isAddress = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: context.smallRadius.circularRadius,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: context.smallIconSize,
              color: context.textSecondary,
            ),
            context.smallSpacing.hSpace,
            SizedBox(
              width: 80.w,
              child: label.toBody(context, color: context.textSecondary),
            ),
            Expanded(
              child: isAddress
                  ? value.toBody(
                      context,
                      color: context.textPrimary,
                      textAlign: value.isMostlyArabic
                          ? TextAlign.right
                          : TextAlign.left,
                    )
                  : value.toBody(
                      context,
                      color: onTap != null
                          ? context.colorScheme.primary
                          : context.textPrimary,
                      fontWeight: onTap != null ? FontWeight.w600 : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceDetailSkeleton extends StatelessWidget {
  const _PlaceDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 220.h,
            color: context.borderColor,
          ),
          Padding(
            padding: context.pagePadding.copyWith(top: context.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: context.roundRadius.circularRadius,
                  ),
                ),
                12.vSpace,
                Container(
                  width: 200.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: context.smallRadius.circularRadius,
                  ),
                ),
                10.vSpace,
                Container(
                  width: 150.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: context.smallRadius.circularRadius,
                  ),
                ),
                24.vSpace,
                Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                            color: context.borderColor,
                            borderRadius: context.mediumRadius.circularRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                24.vSpace,
                Container(
                  width: double.infinity,
                  height: 130.h,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: context.mediumRadius.circularRadius,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).shimmerLoop();
  }
}

class _PlaceDetailErrorView extends StatelessWidget {
  final Failure failure;

  const _PlaceDetailErrorView({required this.failure});

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(errorIcon, size: 54.r, color: context.iconColor),
              context.smallSpacing.vSpace,
              failure.message.toBody(
                context,
                color: context.textSecondary,
                textAlign: TextAlign.center,
              ),
              context.mediumSpacing.vSpace,
              ElevatedButton(
                onPressed: () =>
                    context.read<PlaceDetailCubit>().loadPlaceDetails(),
                child: 'حاول تاني'.toBody(
                  context,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ).fadeSlideIn(),
        ),
      ),
    );
  }
}
