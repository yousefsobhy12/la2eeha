import 'package:flutter/material.dart';
import 'package:la2eeha/core/widgets/custom_button.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CustomElevatedButton)
Widget defaultCustomButton(BuildContext context) {
  return Center(
    child: CustomElevatedButton(
      text: context.knobs.string(label: 'Text', initialValue: 'احجز الان'),
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'Loading', type: CustomElevatedButton)
Widget loadingCustomButton(BuildContext context) {
  return Center(
    child: CustomElevatedButton(
      text: 'احجز الان',
      isLoading: true,
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'Outlined', type: CustomElevatedButton)
Widget outlinedCustomButton(BuildContext context) {
  return Center(
    child: CustomElevatedButton(
      text: 'احجز الان',
      isOutlined: true,
      onPressed: () {},
    ),
  );
}