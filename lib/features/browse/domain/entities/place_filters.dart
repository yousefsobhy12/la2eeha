// lib/features/browse/domain/entities/place_filters.dart
//
// فلاتر عرض الأماكن — value object صغير بيعدّي مع الـ state من الـ Cubit
// لحد الـ query في الـ datasource. كل فلاجس بتاخد قيمة bool واحدة، والـ default
// (كله false) معناها "مفيش فلترة" فالـ query بيفضل زي ما هو بالظبط.
//
// الفلاتر متعمدين نخليها في entity منفصلة (مش bools مبعثرة في الـ state)
// عشان قيمة واحدة كاملة بتتمرّر للـ repository، وقابلية المقارنة بتخلّي
// الـ Cubit يعرف إن الفلاتر اتغيّرت من غير ما يعمل state جديد على الفاضي.

class PlaceFilters {
  /// المكان مفتوح دلوقتي — بيتحول لـ eq على عمود is_open_now.
  final bool openNow;

  /// المكان بيقدّم خدمة توصيل — بيتحول لـ eq على عمود is_delivery.
  final bool delivery;

  const PlaceFilters({this.openNow = false, this.delivery = false});

  /// في فلتر واحد مفعّل على الأقل — الشاشة بتستخدمه عشان تعرض أو تخفي
  /// تلميح "في فلتر مفعّل" وزرار مسح الفلاتر.
  bool get isActive => openNow || delivery;

  /// عدد الفلاتر المفعّلة — بيظهر في العنصر/الـ badge بتاع الفلاتر.
  int get activeCount => (openNow ? 1 : 0) + (delivery ? 1 : 0);

  PlaceFilters copyWith({bool? openNow, bool? delivery}) {
    return PlaceFilters(
      openNow: openNow ?? this.openNow,
      delivery: delivery ?? this.delivery,
    );
  }

  // == و hashCode مكتوبين بإيدنا (مفيش equatable في المشروع) عشان الـ Cubit
  // يقدر يقارن الفلاتر القديمة بالجديدة ويعرف لو محتاج re-query.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceFilters &&
        other.openNow == openNow &&
        other.delivery == delivery;
  }

  @override
  int get hashCode => Object.hash(openNow, delivery);
}
