import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/place_filters.dart';

class PlaceFiltersSheet {
  const PlaceFiltersSheet._();

  static Future<void> show(
    BuildContext context, {
    required PlaceFilters initial,
    required bool showDelivery,
    required ValueChanged<PlaceFilters> onChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.extraLargeRadius),
        ),
      ),
      builder: (sheetContext) => _PlaceFiltersSheetBody(
        initial: initial,
        showDelivery: showDelivery,
        onChanged: onChanged,
      ),
    );
  }
}

class _PlaceFiltersSheetBody extends StatefulWidget {
  final PlaceFilters initial;
  final bool showDelivery;
  final ValueChanged<PlaceFilters> onChanged;

  const _PlaceFiltersSheetBody({
    required this.initial,
    required this.showDelivery,
    required this.onChanged,
  });

  @override
  State<_PlaceFiltersSheetBody> createState() => _PlaceFiltersSheetBodyState();
}

class _PlaceFiltersSheetBodyState extends State<_PlaceFiltersSheetBody> {
  late PlaceFilters _filters = widget.showDelivery
      ? widget.initial
      : widget.initial.copyWith(delivery: false);

  void _update(PlaceFilters next) {
    final resolved = !widget.showDelivery && next.delivery
        ? next.copyWith(delivery: false)
        : next;
    setState(() => _filters = resolved);
    widget.onChanged(resolved);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: context.bottomSheetPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: context.bottomSheetDragHandleWidth,
                    height: context.bottomSheetDragHandleHeight,
                    margin: EdgeInsets.only(bottom: context.largeSpacing),
                    decoration: BoxDecoration(
                      color: context.borderColor,
                      borderRadius: 4.circularRadius,
                    ),
                  ),
                ),
                'تصفية النتائج'.toTitle(context, fontWeight: FontWeight.bold),
                context.mediumSpacing.vSpace,
                _FilterSwitchRow(
                  label: 'مفتوح دلوقتي',
                  value: _filters.openNow,
                  onChanged: (value) =>
                      _update(_filters.copyWith(openNow: value)),
                ),
                if (widget.showDelivery) ...[
                  context.smallSpacing.vSpace,
                  _FilterSwitchRow(
                    label: 'متاح توصيل',
                    value: _filters.delivery,
                    onChanged: (value) =>
                        _update(_filters.copyWith(delivery: value)),
                  ),
                ],
                if (_filters.isActive) ...[
                  context.mediumSpacing.vSpace,
                  CustomElevatedButton(
                    text: 'مسح الفلاتر',
                    onPressed: () => _update(const PlaceFilters()),
                    isOutlined: true,
                    backgroundColor: context.colorScheme.primary,
                    height: 48,
                    fontSize: 14,
                    borderRadius: 12,
                  ),
                ],
                context.mediumSpacing.vSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.mediumSpacing),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.mediumRadius.circularRadius,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(child: label.toBody(context, fontWeight: FontWeight.w600)),
          Switch(
            value: value,
            activeThumbColor: context.colorScheme.onPrimary,
            activeTrackColor: context.colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
