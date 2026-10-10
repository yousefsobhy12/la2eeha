import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

class UnsavedChangesBar extends StatelessWidget {
  final bool visible;
  final String message;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onPressed;

  const UnsavedChangesBar({
    super.key,
    required this.visible,
    required this.message,
    required this.buttonText,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: visible
          ? _buildBar(context)
          : const SizedBox(
              key: ValueKey('unsaved-bar-hidden'),
              width: double.infinity,
            ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return Container(
      key: const ValueKey('unsaved-bar-visible'),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.hSpacing,
        10,
        context.hSpacing,
        10 + context.bottomSafeArea,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.edit_note_rounded, color: context.colorScheme.primary),
          8.hSpace,
          Expanded(
            // plain Text on purpose (maxLines 2), NOT .toBody(): toBody shrinks to one line
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyBold14(context.textPrimary),
            ),
          ),
          8.hSpace,
          CustomElevatedButton(
            text: buttonText,
            isLoading: isLoading,
            onPressed: onPressed,
            width: 110,
            height: 44,
            fontSize: 14,
            backgroundColor: AppColors.primary,
            textColor: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
            borderRadius: context.largeRadius,
            boxShadow: const [],
          ),
        ],
      ),
    );
  }
}
