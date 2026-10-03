import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Central place to tweak the "personality" of animations app-wide.
/// غيّر القيم هنا وكل الشاشات اللي بتستخدم الـ extensions دي هتتأثر.
class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 450);
  static const Duration slow = Duration(milliseconds: 650);

  /// المسافة الزمنية بين كل عنصر والتاني في قائمة عناصر بتظهر staggered
  static const Duration staggerStep = Duration(milliseconds: 70);

  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve popCurve = Curves.easeOutBack;

  /// بيرجع delay مناسب لعنصر رقم [index] في قائمة (لعمل stagger effect)
  static Duration stagger(int index, {Duration? base}) {
    return (base ?? Duration.zero) + (staggerStep * index);
  }
}

extension WidgetAnimationExtension on Widget {
  // ════════════════════════════════════════════════════════════
  // ENTRANCE ANIMATIONS
  // ════════════════════════════════════════════════════════════

  /// Fade + slide من تحت لفوق — مناسب لأي عنصر بيظهر في الشاشة
  /// (headers, fields, cards, list items...)
  Widget fadeSlideIn({
    Duration delay = Duration.zero,
    Duration duration = AppAnimations.normal,
    double beginOffsetY = 0.08,
    Curve curve = AppAnimations.entranceCurve,
  }) {
    return animate()
        .fadeIn(delay: delay, duration: duration, curve: curve)
        .slideY(
          begin: beginOffsetY,
          end: 0,
          delay: delay,
          duration: duration,
          curve: curve,
        );
  }

  /// Fade + slide من اليمين/الشمال — مفيد للعناصر اللي بتدخل من الجنب
  Widget fadeSlideInX({
    Duration delay = Duration.zero,
    Duration duration = AppAnimations.normal,
    double beginOffsetX = 0.1,
    Curve curve = AppAnimations.entranceCurve,
  }) {
    return animate()
        .fadeIn(delay: delay, duration: duration, curve: curve)
        .slideX(
          begin: beginOffsetX,
          end: 0,
          delay: delay,
          duration: duration,
          curve: curve,
        );
  }

  /// Fade + scale "pop" — مناسب للوجو، الأيقونات، البادجز
  Widget popIn({
    Duration delay = Duration.zero,
    Duration duration = AppAnimations.normal,
    double beginScale = 0.85,
  }) {
    return animate()
        .fadeIn(delay: delay, duration: duration)
        .scale(
          begin: Offset(beginScale, beginScale),
          end: const Offset(1, 1),
          delay: delay,
          duration: duration,
          curve: AppAnimations.popCurve,
        );
  }

  /// Fade بسيط من غير حركة — لعناصر تانوية زي الـ dividers والنصوص الصغيرة
  Widget fadeOnly({
    Duration delay = Duration.zero,
    Duration duration = AppAnimations.fast,
  }) {
    return animate().fadeIn(delay: delay, duration: duration);
  }

  // ════════════════════════════════════════════════════════════
  // TOGGLE / SWAP ANIMATIONS
  // ════════════════════════════════════════════════════════════

  /// تبديل أيقونة بأنيميشن ناعم (دوران أفقي 2.5D + pop + fade)
  /// استخدمها للأيقونات اللي بتتبدّل زي عين كلمة السر أو أي toggle
  ///
  /// ملاحظة مهمة: الـ key لازم يتمرر هنا (مش على الـ child)، لأن Animate
  /// بيبدأ الأنيميشن في initState بس. من غير key مختلف كل مرة، الـ element
  /// بيتعاد استخدامه والأنيميشن مش هيشتغل تاني.
  Widget iconSwap({
    Key? key,
    Duration duration = AppAnimations.fast,
    Curve curve = Curves.easeOutCubic,
    double beginScale = 0.6,
    bool flip = true,
  }) {
    var manager = animate(key: key)
        .fadeIn(duration: duration, curve: curve)
        .scale(
          begin: Offset(beginScale, beginScale),
          end: const Offset(1, 1),
          duration: duration,
          curve: AppAnimations.popCurve,
        );

    if (flip) {
      manager = manager.flip(
        begin: 0.5,
        end: 0,
        direction: Axis.horizontal,
        alignment: Alignment.center,
        duration: duration,
        curve: curve,
      );
    }

    return manager;
  }

  // ════════════════════════════════════════════════════════════
  // INTERACTIVE / LOOPING ANIMATIONS
  // ════════════════════════════════════════════════════════════

  /// Shimmer خفيف بيتكرر — مفيد لأي CTA عايز تلفت النظر له (زرار رئيسي مثلاً)
  Widget shimmerLoop({
    Duration duration = const Duration(milliseconds: 1800),
    Color? color,
  }) {
    return animate(
      onPlay: (c) => c.repeat(),
    ).shimmer(duration: duration, color: color ?? Colors.white24);
  }

  /// نبضة خفيفة بتتكرر — لتنبيه لطيف (badges, notification dots)
  Widget pulseLoop({
    Duration duration = const Duration(milliseconds: 1200),
    double maxScale = 1.06,
  }) {
    return animate(onPlay: (c) => c.repeat(reverse: true)).scale(
      begin: const Offset(1, 1),
      end: Offset(maxScale, maxScale),
      duration: duration,
      curve: Curves.easeInOut,
    );
  }
}

/// Helper لعمل staggered entrance لقائمة widgets بسهولة:
///   children: AppAnimations.staggeredChildren([w1, w2, w3]),
extension StaggeredListAnimation on List<Widget> {
  List<Widget> staggered({
    Duration base = Duration.zero,
    Duration step = AppAnimations.staggerStep,
    double beginOffsetY = 0.08,
  }) {
    return [
      for (var i = 0; i < length; i++)
        this[i].fadeSlideIn(
          delay: base + (step * i),
          beginOffsetY: beginOffsetY,
        ),
    ];
  }
}
