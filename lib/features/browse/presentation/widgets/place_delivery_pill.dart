// lib/features/browse/presentation/widgets/place_delivery_pill.dart
//
// بادج "توصيل" — بيظهر بس للأماكن اللي عندها is_delivery مفعّل. الشكل
// بييجي من PlacePill (نفس بادج حالة الفتح بالظبط) واللي بيتغير هنا هو
// النص واللون بس.

import 'package:flutter/material.dart';

import 'place_pill.dart';

class PlaceDeliveryPill extends StatelessWidget {
  const PlaceDeliveryPill({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlacePill(label: 'توصيل', color: Color(0xFF1F5F8B));
  }
}
