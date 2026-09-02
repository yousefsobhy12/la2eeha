import 'package:flutter/material.dart';
import 'package:la2eeha/core/theme/app_text_styles.dart';

import '../../../../core/extensions/extensions.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        'لاقيها'.toResponsiveText(
          context,
          style: AppTextStyles.brandLogo(context.textSecondary),
        ),
        SizedBox(height: ResponsiveValues.spacing4),
        'v1.0 — MVP'.toResponsiveText(
          context,
          style: AppTextStyles.versionLabel(context.textSecondary),
        ),
      ],
    );
  }
}