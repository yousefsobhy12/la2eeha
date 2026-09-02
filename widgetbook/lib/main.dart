import 'package:flutter/material.dart';
import 'package:la2eeha_widgetbook/main.directories.g.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() {
  runApp(WidgetBookApp());
}

@widgetbook.App()
class WidgetBookApp extends StatelessWidget {
  const WidgetBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        ViewportAddon([
          Viewports.none,
          AndroidViewports.samsungGalaxyA50,
          IosViewports.iPhone13,
          IosViewports.iPadPro11Inches,
          ]),
      ],
    );
  }
}
