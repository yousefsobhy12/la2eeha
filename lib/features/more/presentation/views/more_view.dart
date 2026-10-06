import 'package:flutter/material.dart';
import 'package:la2eeha/core/widgets/colored_section_header.dart';
import 'package:la2eeha/features/more/presentation/widgets/business_owner_card.dart';
import 'package:la2eeha/features/more/presentation/widgets/contact_bottom_sheet.dart';
import 'package:la2eeha/features/more/presentation/widgets/contact_card.dart';
import 'package:la2eeha/features/more/presentation/widgets/dark_mode_toggle_card.dart';
import 'package:la2eeha/features/more/presentation/widgets/footer.dart';
import '../../../../core/extensions/extensions.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.extraLargeRadius),
        ),
      ),
      builder: (sheetContext) => const ContactSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const ColoredSectionHeader(
            title: 'المزيد',
            subtitle: 'حساب التجار والتواصل معنا',
          ),
          Padding(
            padding: context.pagePadding,
            child: Column(
              children: [
                SizedBox(height: context.largeSpacing),
                const BusinessOwnerCard(),
                SizedBox(height: context.mediumSpacing),
                ContactCard(onTap: () => _showContactSheet(context)),
                SizedBox(height: context.mediumSpacing),
                const DarkModeToggleCard(),
                SizedBox(height: context.extraLargeSpacing),
                SizedBox(height: context.extraLargeSpacing),
                const Footer(),
                SizedBox(height: context.largeSpacing),
                context.isTablet ||
                        context.isMobileOrSmallTablet ||
                        context.isSmallPhone
                    ? SizedBox(height: context.extraLargeSpacing * 2)
                    : const SizedBox(),
              ],
            ),
          ),
        ].staggered(),
      ),
    );
  }
}
