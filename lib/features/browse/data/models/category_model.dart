// lib/features/browse/data/models/category_model.dart
//
// نسخة من Category بس بتعرف تتحول من/لـ JSON.
// دي اللي بتتكلم فعليًا مع Supabase، مش الـ entity النضيف.

import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.icon,
  });

  // بيحول الـ JSON اللي راجع من Supabase لكائن CategoryModel
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      icon: json['icon'] as String,
    );
  }

  // بيحول الكائن لـ JSON (مش هنحتاجه كتير دلوقتي لأن categories مقروءة بس،
  // بس بنضيفه دايمًا كعادة ثابتة لكل Model)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name_ar': nameAr, 'name_en': nameEn, 'icon': icon};
  }
}
