// lib/features/browse/presentation/widgets/category_grid.dart
//
// 🔧 الشبكة هنا ثابتة 4 أعمدة زي التصميم بالظبط (مش context.gridColumns
// العام اللي بيرجع 2 على الموبايل) — قرار تصميمي مقصود لأن التصميم محدد صراحة.
// ✅ راوت '/places' و'/category/{id}' لسه مش موجودين في app_router.dart —
// بيعرضوا "قريبًا" لحد ما CategoryListView تتبني (Section 13.1). لما تتبني،
// بدّل showComingSoon بـ context.push(...) للراوت الفعلي.

import 'package:flutter/material.dart';

import '../../../../core/constants/category_visuals.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../domain/entities/category.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;

  const CategoryGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: context.smallSpacing,
      crossAxisSpacing: context.smallSpacing,
      childAspectRatio: 0.85,
      children: [
        _CategoryTile(
          label: 'الكل',
          visual: CategoryVisuals.all,
          onTap: () => showComingSoon(context),
        ),
        ...categories.map(
          (category) => _CategoryTile(
            label: category.nameAr,
            visual: CategoryVisuals.of(category.icon),
            onTap: () => showComingSoon(context),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final CategoryVisual visual;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.label,
    required this.visual,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: context.largeRadius.circularRadius,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: context.largeAvatarSize,
            height: context.largeAvatarSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  visual.color.withValues(alpha: 0.20),
                  visual.color.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: context.largeRadius.circularRadius,
              boxShadow: [
                BoxShadow(
                  color: visual.color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(visual.icon, color: visual.color, size: context.largeIconSize),
          ),
          6.vSpace,
          label.toCaption(context, color: context.textPrimary, maxLines: 1),
        ],
      ),
    );
  }
}
