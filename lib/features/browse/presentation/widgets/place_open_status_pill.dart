import 'package:flutter/material.dart';

import '../../domain/entities/place_open_status.dart';
import 'place_pill.dart';

class PlaceOpenStatusPill extends StatelessWidget {
  final PlaceOpenStatus? status;

  const PlaceOpenStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    // الشكل نفسه بقى في PlacePill — هنا بنحسب النص واللون بس.
    final (String label, Color color) = switch (status!) {
      PlaceOpenStatus.openNow => ('مفتوح الآن', const Color(0xFF2F6B3A)),
      PlaceOpenStatus.closedNow => ('مغلق الآن', const Color(0xFF8C2F39)),
      PlaceOpenStatus.closedToday => ('مغلق اليوم', const Color(0xFF8C2F39)),
    };

    return PlacePill(label: label, color: color);
  }
}
