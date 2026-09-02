// lib/features/browse/presentation/widgets/category_grid.dart
//
// 🔧 الشبكة بقت SliverGrid — بتستخدم context.categoryGridColumns عشان عدد
// الأعمدة يتغير حسب حجم الشاشة (3 صغير / 4 موبايل / 5 كبير / 6 تابلت+)
// و context.categoryGridAspectRatio عشان شكل البلاطة يفضل متناسب.
// ✅ راوت '/places' و'/category/{id}' متوصلين بـ CategoryListView.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/category_visuals.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/category.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;

  const CategoryGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: context.smallSpacing,
        crossAxisSpacing: context.smallSpacing,
        childAspectRatio: context.categoryGridAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final Widget tile;
        if (index == 0) {
          tile = _CategoryTile(
            label: 'الكل',
            visual: CategoryVisuals.all,
            onTap: () => context.push('/places'),
          );
        } else {
          final category = categories[index - 1];
          tile = _CategoryTile(
            label: category.nameAr,
            visual: CategoryVisuals.of(category.icon),
            onTap: () => context.push('/category/${category.id}'),
          );
        }
        return tile.fadeSlideIn(
          delay: AppAnimations.stagger(
            index,
            base: const Duration(milliseconds: 60),
          ),
        );
      }, childCount: categories.length + 1),
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
            child: Icon(
              visual.icon,
              color: visual.color,
              size: context.largeIconSize,
            ),
          ),
          6.vSpace,
          label.toCaption(context, color: context.textPrimary, maxLines: 1),
        ],
      ),
    );
  }
}
