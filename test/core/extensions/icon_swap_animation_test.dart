import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la2eeha/core/extensions/animation_extension.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: IconButton(
          onPressed: () => setState(() => obscureText = !obscureText),
          icon: obscureText
              ? const Icon(Icons.visibility)
                  .iconSwap(key: const ValueKey('opened'), flip: false)
              : const Icon(Icons.visibility_off)
                  .iconSwap(key: const ValueKey('closed')),
        ),
      ),
    );
  }
}

/// Matrices of the Transforms produced by `iconSwap`, outermost first.
///
/// Effects are applied in registration order, so the tree nests them as
/// `flip > scale > fade > child`. `FadeEffect` renders an `Opacity`, so only
/// the flip and the scale show up as `Transform`s.
List<Matrix4> effectMatrices(WidgetTester tester) {
  final result = <Matrix4>[];
  for (final element in find.byType(Transform).evaluate()) {
    var inside = false;
    element.visitAncestorElements((e) {
      if (e.widget.runtimeType.toString() == 'Animate') {
        inside = true;
        return false;
      }
      return true;
    });
    if (inside) result.add((element.widget as Transform).transform);
  }
  return result;
}

/// cos(angle) of the 2.5D flip, or null when no flip effect is applied.
///
/// `vector_math` lays `Matrix4` out column-major, so the cosine of the Y
/// rotation lands in `storage[0]`: 1.0 == flat, ~0 == turned 90 degrees.
double? flipCos(WidgetTester tester) {
  final matrices = effectMatrices(tester);
  if (matrices.length < 2) return null;
  return matrices.first.storage[0];
}

/// Scale factor, 1.0 when the icon sits at its resting size.
double iconScale(WidgetTester tester) =>
    effectMatrices(tester).last.storage[0];

/// Taps, then pumps enough frames for Animate's zero-delay `_play()` to run.
Future<void> toggle(WidgetTester tester) async {
  await tester.tap(find.byType(IconButton));
  await tester.pump();
  await tester.pump();
}

/// Pumps small frames until [condition] holds, so the assertion does not
/// depend on how many frames the ticker needs to spin up.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition,
) async {
  for (var i = 0; i < 30 && !condition(); i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('iconSwap replays on every toggle', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pumpAndSettle();

    // entrance finished -> flat and full size
    expect(iconScale(tester), closeTo(1, 0.001));
    expect(flipCos(tester), isNull, reason: 'flip:false branch has no flip');

    // 1st toggle -> animation must restart from the shrunk/rotated state
    await toggle(tester);
    expect(iconScale(tester), lessThan(0.9));
    expect(flipCos(tester), closeTo(0, 0.2));

    // ...and animate back towards flat/full size
    await pumpUntil(tester, () => iconScale(tester) > 0.6);
    expect(iconScale(tester), greaterThan(0.6));
    expect(flipCos(tester), greaterThan(0));
    expect(flipCos(tester), lessThan(1));

    await tester.pumpAndSettle();
    expect(iconScale(tester), closeTo(1, 0.001));
    expect(flipCos(tester), closeTo(1, 0.001));

    // 2nd toggle -> must replay again rather than stay settled
    await toggle(tester);
    expect(iconScale(tester), lessThan(0.9));
    expect(flipCos(tester), isNull);

    await tester.pumpAndSettle();
    expect(iconScale(tester), closeTo(1, 0.001));
  });
}