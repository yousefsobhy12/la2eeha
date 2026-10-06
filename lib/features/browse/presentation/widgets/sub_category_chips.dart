import 'package:flutter/material.dart';

import '../../../../core/constants/sub_category_visuals.dart';
import '../../../../core/extensions/extensions.dart';

class SubCategoryChips extends StatelessWidget {
  final List<String> subCategories;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const SubCategoryChips({
    super.key,
    required this.subCategories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (subCategories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: context.buttonHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: context.pagePadding,
        itemCount: subCategories.length + 1,
        separatorBuilder: (_, index) => context.smallSpacing.hSpace,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final value = isAll ? null : subCategories[index - 1];
          final isSelected = selected == value;
          final label = isAll
              ? 'الكل'
              : SubCategoryVisuals.labelOf(value, fallback: value ?? '');

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelect(value),
            selectedColor: context.colorScheme.primary,
            backgroundColor: context.colorScheme.primary.withValues(
              alpha: 0.08,
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? context.colorScheme.onPrimary
                  : context.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.borderColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: context.roundRadius.circularRadius,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
