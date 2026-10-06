import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:la2eeha/core/theme/app_colors.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/extensions.dart';

// ignore_for_file: unused_element

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
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) =>
            LiquidTabBarController.shared.handleScroll(notification),
        child: navigationShell,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: context.bottomSafeArea),
        child: LiquidTabBar(
          items: [
            LiquidTabItem.icon(
              label: 'الرئيسية',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
            ),
            LiquidTabItem.icon(
              label: 'المفضلة',
              icon: Icons.favorite_border_rounded,
              activeIcon: Icons.favorite,
            ),
            LiquidTabItem.icon(
              label: 'المزيد',
              icon: Icons.menu_rounded,
              activeIcon: Icons.menu_rounded,
            ),
          ],
          theme: LiquidTabBarTheme(
            activeColor: context.isDarkMode
                ? AppColors.textMuted
                : AppColors.primary,
            inactiveColor: context.isDarkMode
                ? AppColors.textSecondary
                : AppColors.onPrimary,
          ),
          selectedIndex: navigationShell.currentIndex,
          onSelected: _onTap,
        ),
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
    _NavItem(icon: Icons.menu_rounded, label: 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final bar = ClipRRect(
      borderRadius: 999.circularRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: context.surfaceColor.withValues(alpha: 0.55),
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
