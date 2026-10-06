import 'package:flutter/material.dart';

import 'place_pill.dart';

class PlaceDeliveryPill extends StatelessWidget {
  const PlaceDeliveryPill({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlacePill(label: 'توصيل', color: Color(0xFF1F5F8B));
  }
}
