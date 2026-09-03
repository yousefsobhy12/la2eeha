import 'package:flutter/material.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DarkModeToggleCard extends StatelessWidget {
  const DarkModeToggleCard({super.key});

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
                size: context.mediumIconSize,
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
