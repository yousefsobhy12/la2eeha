import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';

class AccountHeader extends StatelessWidget {
  const AccountHeader({
    super.key,
    required this.name,
    required this.email,
    required this.totalPlaces,
    required this.approvedPlaces,
  });

  final String name;
  final String email;
  final int? totalPlaces;
  final int? approvedPlaces;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.hSpacing,
        context.topSafeArea,
        context.hSpacing,
        context.largeSpacing,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: 22.bottomRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'حسابي'.toCaption(
                      context,
                      color: context.colorScheme.onPrimary,
                    ),
                    name.toTitle(
                      context,
                      color: context.colorScheme.onPrimary,
                      fontFamily: AppFonts.reemKufi,
                      maxLines: 1,
                    ),
                    email.toCaption(
                      context,
                      color: context.colorScheme.onPrimary,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: context.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          context.largeSpacing.vSpace,
          Row(
            children: [
              Expanded(
                child: _StatBox(label: 'أماكني', value: totalPlaces),
              ),
              context.mediumSpacing.hSpace,
              Expanded(
                child: _StatBox(label: 'منشورة', value: approvedPlaces),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.08),
        borderRadius: context.mediumRadius.circularRadius,
      ),
      child: Column(
        children: [
          (value?.toString() ?? '–').toTitle(
            context,
            color: context.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          label.toCaption(context, color: context.colorScheme.onPrimary),
        ],
      ),
    );
  }
}
