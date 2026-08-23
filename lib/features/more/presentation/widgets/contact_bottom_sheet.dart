import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:la2eeha/core/constants/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/constants/contact_links.dart';

Future<void> _launchContactLink(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class ContactSheet extends StatelessWidget {
  const ContactSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      children: [
        'تواصل معنا'.toHeadline(context, color: context.textPrimary),
        context.smallSpacing.vSpace,
        'عندك اقتراح، مشكلة، أو مكان ناقص؟'.toCaption(
          context,
          color: context.textSecondary,
        ),
        context.largeSpacing.vSpace,

        _BigActionButton(
          icon: AppIcons.whatsappIcon,
          label: 'راسلنا على واتساب',
          background: const Color(0xFF25D366).withValues(alpha: 0.14),
          foreground: const Color(0xFF128C4A),
          onTap: () => _launchContactLink(ContactLinks.whatsappUrl),
        ),
        context.smallSpacing.vSpace,

        _BigActionButton(
          icon: AppIcons.gmailIcon,
          label: 'راسلنا بالإيميل',
          background: const Color(0xFFEA4335).withValues(alpha: 0.12),
          foreground: const Color(0xFFEA4335),
          tintIcon: false,
          onTap: () => _launchContactLink(ContactLinks.emailUrl),
        ),

        context.largeSpacing.vSpace,
        _FollowButton(
          icon: AppIcons.facebookIcon,
          label: 'تابعنا على فيسبوك',
          color: const Color(0xFF1877F2), // Facebook brand blue
          onTap: () => _launchContactLink(ContactLinks.facebookPageUrl),
        ),
      ],
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  final bool tintIcon;

  const _BigActionButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.tintIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: context.largeRadius.circularRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.largeRadius.circularRadius,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.hSpacing,
            vertical: context.mediumSpacing,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                colorFilter: tintIcon
                    ? ColorFilter.mode(foreground, BlendMode.srcIn)
                    : null,
                height: context.mediumIconSize,
              ),
              context.hSpacing.hSpace,
              Expanded(
                child: label.toBody(
                  context,
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14.r, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  final List<Widget> children;

  const _SheetShell({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.extraLargeRadius),
            topRight: Radius.circular(context.extraLargeRadius),
          ),
        ),
        padding: context.bottomSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: context.largeSpacing),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: 4.circularRadius,
                ),
              ),
            ),
            ...children,
            SizedBox(height: context.largeSpacing),
          ],
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FollowButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: context.roundRadius.circularRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: context.roundRadius.circularRadius,
          child: Container(
            constraints: BoxConstraints(minHeight: 44.h),
            padding: EdgeInsets.symmetric(
              horizontal: context.mediumSpacing,
              vertical: context.smallSpacing,
            ),
            decoration: BoxDecoration(
              borderRadius: context.roundRadius.circularRadius,
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  icon,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  height: context.smallIconSize,
                ),
                context.smallSpacing.hSpace,
                label.toCaption(context, color: color, fontWeight: FontWeight.w700),
              ],
            ),
          ),
        ),
      ),
    );
  }
}