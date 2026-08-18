import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:la2eeha/core/theme/cubit/theme_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/contact_links.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart'; // ⚠️ عدّل المسار حسب مكانه عندك

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.extraLargeRadius),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: context.pagePadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: context.mediumSpacing),
                'تواصل معانا'.toResponsiveText(
                  context,
                  style: AppTextStyles.cardTitle(context.textPrimary),
                ),
                SizedBox(height: context.mediumSpacing),
                _ContactOption(
                  icon: Icons.chat_rounded,
                  label: 'واتساب',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openLink(context, ContactLinks.whatsappUrl);
                  },
                ),
                _ContactOption(
                  icon: Icons.facebook_rounded,
                  label: 'فيسبوك',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openLink(context, ContactLinks.facebookPageUrl);
                  },
                ),
                _ContactOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'إنستجرام',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openLink(context, ContactLinks.instagramUrl);
                  },
                ),
                _ContactOption(
                  icon: Icons.email_rounded,
                  label: 'إيميل',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openLink(context, ContactLinks.emailUrl);
                  },
                ),
                SizedBox(height: context.smallSpacing),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _Header(),
          Padding(
            padding: context.pagePadding,
            child: Column(
              children: [
                SizedBox(height: context.largeSpacing),
                const _BusinessOwnerCard(),
                SizedBox(height: context.mediumSpacing),
                _ContactCard(onTap: () => _showContactSheet(context)),
                SizedBox(height: context.mediumSpacing),
                const _DarkModeToggleCard(),
                SizedBox(height: context.extraLargeSpacing),
                SizedBox(height: context.extraLargeSpacing),
                const _Footer(),
                SizedBox(height: context.largeSpacing),
              ],
            ),
          ),
        ].staggered(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.hSpacing,
        vertical: context.largeSpacing,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22.r),
          bottomRight: Radius.circular(22.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // = يمين في RTL
        children: [
          SizedBox(height: context.largeSpacing),
          'المزيد'.toResponsiveText(
            context,
            style: AppTextStyles.headerTitle(context.colorScheme.onPrimary),
          ),
          SizedBox(height: 4.h),
          'حساب التجار والتواصل معنا'.toResponsiveText(
            context,
            style: AppTextStyles.headerSubtitle(
              context.colorScheme.onPrimary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessOwnerCard extends StatelessWidget {
  const _BusinessOwnerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border.all(color: context.borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(context.extraLargeRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(context.largeRadius),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: context.colorScheme.primary,
              size: 22.r,
            ),
          ),
          SizedBox(height: context.mediumSpacing),
          'هل أنت صاحب بيزنس؟'.toResponsiveText(
            context,
            style: AppTextStyles.cardTitle(context.textPrimary),
          ),
          SizedBox(height: 8.h),
          'سجّل مكانك في لاقيها وخلي أهل شبين القناطر\nوالقرى المجاورة يلاقوك بسهولة.'
              .toResponsiveText(
                context,
                textAlign: TextAlign.start,
                style: AppTextStyles.bodyRegular13(context.textSecondary),
              ),
          SizedBox(height: context.mediumSpacing),
          CustomElevatedButton(
            text: 'دخول التجار',
            onPressed: () {
              // ⚠️ TODO Phase 6
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('قريبًا')));
            },
            // ثابتة عن قصد في الوضعين (هوية الزرار الأساسي للبراند)
            backgroundColor: AppColors.primary,
            textColor: AppColors.onPrimary,
            height: 52.h,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            borderRadius: 12.r,
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryPressedShadow,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border.all(color: context.borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(context.extraLargeRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: context.cardPadding,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: context.textSecondary,
                size: 21.r,
              ),
              SizedBox(width: context.smallSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'تواصل مع المطور'.toResponsiveText(
                      context,
                      style: AppTextStyles.bodyBold14(context.textPrimary),
                    ),
                    'اقتراح، مشكلة، أو مكان ناقص'.toResponsiveText(
                      context,
                      style: AppTextStyles.captionRegular12(
                        context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.smallSpacing),
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: context.textSecondary,
                size: 16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// كارت جديد: تبديل الوضع الليلي — Cubit-driven
class _DarkModeToggleCard extends StatelessWidget {
  const _DarkModeToggleCard();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border.all(color: context.borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(context.extraLargeRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.read<ThemeCubit>().toggleTheme(),
        child: Padding(
          padding: context.cardPadding,
          child: Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: context.textSecondary,
                size: 20.r,
              ),
              SizedBox(width: context.smallSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'الوضع الليلي'.toResponsiveText(
                      context,
                      style: AppTextStyles.bodyBold14(context.textPrimary),
                    ),
                    'يريّح عينك في الإضاءة الخفيفة'.toResponsiveText(
                      context,
                      style: AppTextStyles.captionRegular12(
                        context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.smallSpacing),
              Switch(
                value: isDark,
                activeColor: context.colorScheme.primary,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        'لاقيها'.toResponsiveText(
          context,
          style: AppTextStyles.brandLogo(context.textSecondary),
        ),
        SizedBox(height: 4.h),
        'v1.0 — MVP'.toResponsiveText(
          context,
          style: AppTextStyles.versionLabel(context.textSecondary),
        ),
      ],
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: context.colorScheme.primary),
      title: label.toResponsiveText(
        context,
        style: AppTextStyles.bodyBold14(context.textPrimary),
      ),
    );
  }
}
