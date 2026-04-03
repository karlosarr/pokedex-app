import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/core/utils/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    test('capitalize should capitalize the first letter of a non-empty string', () {
      expect('hello'.capitalize(), 'Hello');
      expect('world'.capitalize(), 'World');
    });

    test('capitalize should return the same string if it is already capitalized', () {
      expect('Hello'.capitalize(), 'Hello');
    });

    test('capitalize should return an empty string if the string is empty', () {
      expect(''.capitalize(), '');
    });

    test('capitalize should handle single character strings', () {
      expect('a'.capitalize(), 'A');
      expect('A'.capitalize(), 'A');
    });

    test('capitalize should only capitalize the first character', () {
      expect('hello world'.capitalize(), 'Hello world');
      expect('hELLO'.capitalize(), 'HELLO');
    });
  });
}
