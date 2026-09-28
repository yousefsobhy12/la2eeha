// lib/features/merchant/domain/entities/sports_pricing_draft.dart
//
// كيان write-only لفترة تسعير ملعب — localKey لعمليات القائمة المحلية
// و id بيبقى null لو الفترة لسه ماتحفظش.

import 'package:flutter/material.dart';

class SportsPricingDraft {
  final String localKey;
  final int? id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double price;

  /// وصف اختياري (أقصى 150 حرف).
  final String? description;

  /// بيتحسب وقت الحفظ من موضع الفترة في القائمة المحلية.
  final int sortOrder;

  const SportsPricingDraft({
    required this.localKey,
    this.id,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.description,
    required this.sortOrder,
  });
}
