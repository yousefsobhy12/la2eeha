import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 450);
  static const Duration slow = Duration(milliseconds: 650);

  static const Duration staggerStep = Duration(milliseconds: 70);

  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve popCurve = Curves.easeOutBack;

  static Duration stagger(int index, {Duration? base}) {
    return (base ?? Duration.zero) + (staggerStep * index);
  }
}

extension WidgetAnimationExtension on Widget {
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

  Widget fadeOnly({
    Duration delay = Duration.zero,
    Duration duration = AppAnimations.fast,
  }) {
    return animate().fadeIn(delay: delay, duration: duration);
  }

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

  Widget shimmerLoop({
    Duration duration = const Duration(milliseconds: 1800),
    Color? color,
  }) {
    return animate(
      onPlay: (c) => c.repeat(),
    ).shimmer(duration: duration, color: color ?? Colors.white24);
  }

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
