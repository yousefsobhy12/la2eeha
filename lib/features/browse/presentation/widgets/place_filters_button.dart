import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/extensions.dart';
import '../../domain/entities/place_filters.dart';

class PlaceFiltersButton extends StatelessWidget {
  final PlaceFilters filters;
  final VoidCallback onPressed;

  final Color? color;

  const PlaceFiltersButton({
    super.key,
    required this.filters,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? context.iconColor;

    return Semantics(
      button: true,
      label: filters.isActive
          ? 'تصفية النتائج, في فلاتر مفعّلة'
          : 'تصفية النتائج',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: iconColor),
            onPressed: onPressed,
          ),
          if (filters.isActive)
            PositionedDirectional(
              top: 8.r,
              end: 8.r,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.primary,
                  border: Border.all(color: context.surfaceColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
