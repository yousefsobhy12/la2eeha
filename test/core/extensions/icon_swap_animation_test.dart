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
              ? const Icon(
                  Icons.visibility,
                ).iconSwap(key: const ValueKey('opened'), flip: false)
              : const Icon(
                  Icons.visibility_off,
                ).iconSwap(key: const ValueKey('closed')),
        ),
      ),
    );
  }
}

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

double? flipCos(WidgetTester tester) {
  final matrices = effectMatrices(tester);
  if (matrices.length < 2) return null;
  return matrices.first.storage[0];
}

double iconScale(WidgetTester tester) => effectMatrices(tester).last.storage[0];

Future<void> toggle(WidgetTester tester) async {
  await tester.tap(find.byType(IconButton));
  await tester.pump();
  await tester.pump();
}

Future<void> pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var i = 0; i < 30 && !condition(); i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('iconSwap replays on every toggle', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.pumpAndSettle();

    expect(iconScale(tester), closeTo(1, 0.001));
    expect(flipCos(tester), isNull, reason: 'flip:false branch has no flip');

    await toggle(tester);
    expect(iconScale(tester), lessThan(0.9));
    expect(flipCos(tester), closeTo(0, 0.2));

    await pumpUntil(tester, () => iconScale(tester) > 0.6);
    expect(iconScale(tester), greaterThan(0.6));
    expect(flipCos(tester), greaterThan(0));
    expect(flipCos(tester), lessThan(1));

    await tester.pumpAndSettle();
    expect(iconScale(tester), closeTo(1, 0.001));
    expect(flipCos(tester), closeTo(1, 0.001));

    await toggle(tester);
    expect(iconScale(tester), lessThan(0.9));
    expect(flipCos(tester), isNull);

    await tester.pumpAndSettle();
    expect(iconScale(tester), closeTo(1, 0.001));
  });
}
