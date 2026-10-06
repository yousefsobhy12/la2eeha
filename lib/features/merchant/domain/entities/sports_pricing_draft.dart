import 'package:flutter/material.dart';

class SportsPricingDraft {
  final String localKey;
  final int? id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double price;

  final String? description;

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
