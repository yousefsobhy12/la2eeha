import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../merchant/data/datasource/merchant_remote_datasource.dart';
import '../../../merchant/data/repositories/merchant_repository_impl.dart';
import '../../../merchant/presentation/cubit/add_place_cubit.dart';
import '../../../merchant/presentation/cubit/my_places_cubit.dart';
import '../../../merchant/presentation/cubit/my_places_state.dart';
import '../../../merchant/presentation/widgets/my_place_card.dart';
import '../widgets/account_header.dart';
import '../widgets/contact_bottom_sheet.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyPlacesCubit(
        MerchantRepositoryImpl(remoteDataSource: MerchantRemoteDataSource()),
      )..load(),
      child: const _AccountBody(),
    );
  }
}

class _AccountBody extends StatelessWidget {
  const _AccountBody();

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.extraLargeRadius),
        ),
      ),
      builder: (sheetContext) => const ContactSheet(),
    );
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text(
          'متأكد إنك عايز تسجّل خروج؟ التاب هيرجع «المزيد»، ومسودة إضافة المكان غير المكتملة هتتمسح.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'تسجيل خروج',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}

    if (Supabase.instance.client.auth.currentSession != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مقدرناش نسجّل الخروج، حاول تاني')),
        );
      }
      return;
    }

    await LocalStorageService().remove(AddPlaceCubit.draftKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: Column(
        children: [
          BlocBuilder<MyPlacesCubit, MyPlacesState>(
            builder: (context, state) {
              final user = Supabase.instance.client.auth.currentUser;
              final metadata =
                  user?.userMetadata ?? const <String, dynamic>{};
              final email = user?.email ?? '';
              final name =
                  (metadata['name'] as String?) ??
                  (metadata['full_name'] as String?) ??
                  email.split('@').first;
              final int? totalPlaces = state is MyPlacesLoaded
                  ? state.places.length
                  : null;
              final int? approvedPlaces = state is MyPlacesLoaded
                  ? state.places.where((place) => place.isApproved).length
                  : null;

              return AccountHeader(
                name: name,
                email: email,
                totalPlaces: totalPlaces,
                approvedPlaces: approvedPlaces,
              );
            },
          ),
          Expanded(
            child: BlocBuilder<MyPlacesCubit, MyPlacesState>(
              builder: (context, state) {
                final loaded = state is MyPlacesLoaded ? state : null;
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<MyPlacesCubit>().load(silent: true),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      if (state is MyPlacesInitial || state is MyPlacesLoading)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: context.extraLargeSpacing,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      else if (state is MyPlacesError)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: context.largeSpacing),
                            child: _buildErrorView(context, state),
                          ),
                        )
                      else if (loaded != null) ...[
                        SliverPadding(
                          padding: context.pagePadding.copyWith(
                            top: context.mediumSpacing,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _buildAddButton(context),
                          ),
                        ),
                        if (loaded.places.isNotEmpty) ...[
                          SliverPadding(
                            padding: context.pagePadding.copyWith(
                              top: context.largeSpacing,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: 'الأماكن المسجّلة'.toTitle(
                                context,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: context.pagePadding.copyWith(
                              top: context.smallSpacing,
                            ),
                            sliver: SliverList.separated(
                              itemCount: loaded.places.length,
                              separatorBuilder: (context, index) =>
                                  context.smallSpacing.vSpace,
                              itemBuilder: (context, index) => MyPlaceCard(
                                item: loaded.places[index],
                              ).fadeSlideIn(delay: AppAnimations.stagger(index)),
                            ),
                          ),
                        ] else
                          SliverPadding(
                            padding: context.pagePadding.copyWith(
                              top: context.largeSpacing,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Center(
                                child: 'لسه مضفتش أي مكان'.toBody(
                                  context,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                      SliverPadding(
                        padding: context.pagePadding.copyWith(
                          top: context.largeSpacing,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _buildSettingsCard(context),
                        ),
                      ),
                      SliverPadding(
                        padding: context.pagePadding.copyWith(
                          top: context.mediumSpacing,
                        ),
                        sliver: SliverToBoxAdapter(
                          child:
                              'كل مكان جديد بيتراجع من الإدارة قبل ما يظهر في التطبيق.'
                                  .toCaption(
                                    context,
                                    color: context.textSecondary,
                                    textAlign: TextAlign.center,
                                  ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: context.extraLargeSpacing * 2,
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

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border.all(color: context.borderColor),
        borderRadius: context.largeRadius.circularRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.chat_bubble_outline,
            title: 'تواصل مع المطور',
            subtitle: 'اقتراح أو مشكلة في حسابك',
            trailing: Icon(
              Icons.chevron_left_rounded,
              color: context.textSecondary,
              size: context.smallIconSize,
            ),
            onTap: () => _showContactSheet(context),
          ),
          Divider(height: 1, color: context.borderColor),
          _SettingsRow(
            icon: Icons.logout_rounded,
            title: 'تسجيل خروج',
            subtitle: 'التاب هيرجع «المزيد» تاني',
            titleColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            iconBackground: Colors.redAccent.withValues(alpha: 0.12),
            onTap: () => _confirmAndLogout(context),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.iconColor,
    this.iconBackground,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;
  final Color? iconBackground;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.cardPadding,
        child: Row(
          children: [
            _buildLeadingIcon(context),
            context.smallSpacing.hSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title.toResponsiveText(
                    context,
                    style: AppTextStyles.bodyBold14(
                      titleColor ?? context.textPrimary,
                    ),
                  ),
                  subtitle.toResponsiveText(
                    context,
                    style: AppTextStyles.captionRegular12(
                      context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              context.smallSpacing.hSpace,
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    final color = iconColor ?? context.textSecondary;
    if (iconBackground == null) {
      return Icon(icon, color: color, size: context.mediumIconSize);
    }
    return Container(
      width: context.cardIconContainerSize,
      height: context.cardIconContainerSize,
      decoration: BoxDecoration(
        color: iconBackground,
        borderRadius: context.mediumRadius.circularRadius,
      ),
      child: Icon(icon, color: color, size: context.cardIconSize),
    );
  }
}
