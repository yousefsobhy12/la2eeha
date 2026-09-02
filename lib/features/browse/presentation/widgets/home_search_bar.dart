// lib/features/browse/presentation/widgets/home_search_bar.dart
//
// ✅ راوت '/search' لسه مش موجود في app_router.dart (شفت الملف الحقيقي) —
// بتعرض "قريبًا" لحد ما SearchResultsView تتبني. لما تتبني، بدّل السطر اللي
// فيه showComingSoon بـ context.push('/search') أو الراوت الفعلي.

import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/coming_soon.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showComingSoon(context),
      borderRadius: context.roundRadius.circularRadius,
      child: Container(
        height: context.textFieldHeight,
        padding: EdgeInsets.symmetric(horizontal: context.hSpacing),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.roundRadius.circularRadius,
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: context.textSecondary),
            context.smallSpacing.hSpace,
            Expanded(
              child: 'ابحث عن مطعم، صيدلية، دكتور...'.toBody(
                context,
                color: context.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
