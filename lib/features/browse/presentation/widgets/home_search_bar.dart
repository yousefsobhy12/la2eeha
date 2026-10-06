import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/extensions.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/search'),
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
