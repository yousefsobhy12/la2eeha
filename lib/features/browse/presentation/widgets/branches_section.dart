import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/branch.dart';

class BranchesSection extends StatefulWidget {
  final List<Branch> branches;
  final String placePhone;
  final String placeName;

  const BranchesSection({
    super.key,
    required this.branches,
    required this.placePhone,
    required this.placeName,
  });

  @override
  State<BranchesSection> createState() => _BranchesSectionState();
}

class _BranchesSectionState extends State<BranchesSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.branches.isEmpty) return const SizedBox.shrink();

    final visibleBranches =
        _expanded ? widget.branches : widget.branches.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'فروعنا'.toTitle(context, fontWeight: FontWeight.bold),
        context.mediumSpacing.vSpace,
        Container(
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
              for (int i = 0; i < visibleBranches.length; i++) ...[
                if (i > 0) Divider(color: context.borderColor, height: 16.h),
                _buildBranchRow(context, visibleBranches[i]),
              ],
            ],
          ),
        ),
        if (widget.branches.length > 3) ...[
          context.smallSpacing.vSpace,
          Center(
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  (_expanded
                          ? 'عرض أقل'
                          : 'عرض المزيد (${widget.branches.length - 3})')
                      .toBody(
                    context,
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: context.mediumIconSize,
                    color: context.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBranchRow(BuildContext context, Branch branch) {
    final phone = branch.phone ?? widget.placePhone;
    final googleMapsLink = branch.googleMapsLink;
    final title = branch.title ?? widget.placeName;
    final description = branch.description;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: context.smallIconSize,
          color: context.textSecondary,
        ),
        context.smallSpacing.hSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title.toBody(
                context,
                fontWeight: FontWeight.w600,
                textAlign: title.isMostlyArabic
                    ? TextAlign.right
                    : TextAlign.left,
              ),
              if (description != null) ...[
                2.vSpace,
                description.toCaption(
                  context,
                  color: context.textSecondary,
                  maxLines: 3,
                  textAlign: description.isMostlyArabic
                      ? TextAlign.right
                      : TextAlign.left,
                ),
              ],
              2.vSpace,
              branch.address.toBody(
                context,
                color: context.textPrimary,
                textAlign: branch.address.isMostlyArabic
                    ? TextAlign.right
                    : TextAlign.left,
                maxLines: 3,
              ),
              2.vSpace,
              phone.toCaption(context, color: context.textSecondary),
            ],
          ),
        ),
        context.smallSpacing.hSpace,
        _BranchActionButton(
          icon: Icons.phone_rounded,
          semanticsLabel: 'اتصال بالفرع',
          onPressed: () => _call(phone),
        ),
        if (googleMapsLink != null)
          _BranchActionButton(
            icon: Icons.location_on_rounded,
            semanticsLabel: 'فتح الخريطة',
            onPressed: () => _openMaps(googleMapsLink),
          ),
      ],
    );
  }

  Future<void> _call(String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      // Swallow errors so a failed launch never crashes the UI.
    }
  }

  Future<void> _openMaps(String link) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Swallow errors so an invalid link never crashes the UI.
    }
  }
}

class _BranchActionButton extends StatelessWidget {
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onPressed;

  const _BranchActionButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: IconButton(
        icon: Icon(icon, size: context.mediumIconSize),
        color: context.colorScheme.primary,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}
