import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:la2eeha/core/extensions/theme_extension.dart';
import '../extensions/extensions.dart'; // بارل الـ extensions بتاعتك

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _RoundedFloatingNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

class _RoundedFloatingNavBar extends StatelessWidget {
  const _RoundedFloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.favorite_border_rounded, label: 'المفضلة'),
    _NavItem(icon: Icons.menu_rounded, label: 'المزيد'), // ثابت لحد Phase 6
  ];

  @override
  Widget build(BuildContext context) {
    // ClipRRect لازم عشان BackdropFilter يقتصر على شكل الكبسولة بس، مش المستطيل كامل
    final bar = ClipRRect(
      borderRadius: 999.circularRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: context.surfaceColor.withValues(
              alpha: 0.55,
            ), // بتتغيّر مع الثيم
            borderRadius: 999.circularRadius,
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < _items.length; i++)
                _NavIconButton(
                  item: _items[i],
                  isSelected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );

    return bar.paddingOnly(left: 16, right: 16, bottom: 16).fadeSlideIn();
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: 999.circularRadius,
          splashColor: context.colorScheme.primary.withValues(alpha: 0.3),
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.entranceCurve,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16.w : 12.w,
              vertical: 12.r,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primary
                  : Colors.transparent,
              borderRadius: 999.circularRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  // على الزجاج: نص داكن شفاف شوية (بيتقرا فوق أي خلفية بسبب البلور)
                  color: isSelected
                      ? context.colorScheme.onPrimary
                      : context.textPrimary.withValues(alpha: 0.75),
                  size: context.largeIconSize,
                ),
                AnimatedSize(
                  duration: AppAnimations.normal,
                  curve: AppAnimations.entranceCurve,
                  child: isSelected
                      ? Padding(
                          padding: EdgeInsetsDirectional.only(start: 6.w),
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: ResponsiveValues.labelLarge(context),
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
