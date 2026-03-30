import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('darkTheme returns a ThemeData', () {
      expect(AppTheme.darkTheme, isA<ThemeData>());
    });

    test('darkTheme uses Material3', () {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('darkTheme has dark brightness', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('darkTheme primary color is redAccent', () {
      expect(AppTheme.darkTheme.colorScheme.primary, Colors.redAccent);
    });

    test('darkTheme scaffold background color is correct', () {
      expect(
        AppTheme.darkTheme.scaffoldBackgroundColor,
        const Color(0xFF14161C),
      );
    });
  });
}
