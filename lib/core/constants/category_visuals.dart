import 'package:flutter/material.dart';

class CategoryVisual {
  final IconData icon;
  final Color color;

  const CategoryVisual({required this.icon, required this.color});
}

class CategoryVisuals {
  CategoryVisuals._();

  static const CategoryVisual fallback = CategoryVisual(
    icon: Icons.storefront_outlined,
    color: Color(0xFF6E5842),
  );

  static const CategoryVisual all = CategoryVisual(
    icon: Icons.apps_rounded,
    color: Color(0xFF6E5842),
  );

  static const Map<String, CategoryVisual> _byIcon = {
    'restaurant': CategoryVisual(
      icon: Icons.restaurant_rounded,
      color: Color(0xFFC1761A),
    ),
    'medical': CategoryVisual(
      icon: Icons.medical_services_rounded,
      color: Color(0xFF1F6F63),
    ),
    'hospital': CategoryVisual(
      icon: Icons.local_hospital_rounded,
      color: Color(0xFF8C2F39),
    ),
    'pharmacy': CategoryVisual(
      icon: Icons.medication_rounded,
      color: Color(0xFF2F6B3A),
    ),
    'shop': CategoryVisual(
      icon: Icons.storefront_rounded,
      color: Color(0xFFB8860F),
    ),
    'sports': CategoryVisual(
      icon: Icons.sports_soccer_rounded,
      color: Color(0xFF35618A),
    ),
    'delivery': CategoryVisual(
      icon: Icons.delivery_dining_rounded,
      color: Color(0xFF6F4E7C),
    ),
  };

  static CategoryVisual of(String iconKey) {
    return _byIcon[iconKey] ?? fallback;
  }
}
