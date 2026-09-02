// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:la2eeha_widgetbook/widgets/custom_button.widgetbook.dart'
    as _la2eeha_widgetbook_widgets_custom_button_widgetbook;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'core',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'widgets',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'CustomElevatedButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _la2eeha_widgetbook_widgets_custom_button_widgetbook
                    .defaultCustomButton,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Loading',
                builder: _la2eeha_widgetbook_widgets_custom_button_widgetbook
                    .loadingCustomButton,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Outlined',
                builder: _la2eeha_widgetbook_widgets_custom_button_widgetbook
                    .outlinedCustomButton,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
