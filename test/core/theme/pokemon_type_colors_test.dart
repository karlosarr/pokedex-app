import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/core/theme/pokemon_type_colors.dart';

void main() {
  group('pokemonTypeColors', () {
    test('should contain all 18 standard Pokémon types', () {
      const expectedTypes = [
        'normal', 'fire', 'water', 'electric', 'grass', 'ice',
        'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
        'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
      ];
      for (final type in expectedTypes) {
        expect(pokemonTypeColors.containsKey(type), isTrue,
            reason: 'Missing type: $type');
      }
    });

    test('should have exactly 18 entries', () {
      expect(pokemonTypeColors.length, 18);
    });
  });

  group('getPokemonTypeColor', () {
    test('should return correct color for fire type', () {
      expect(getPokemonTypeColor('fire'), const Color(0xFFEE8130));
    });

    test('should return correct color for water type', () {
      expect(getPokemonTypeColor('water'), const Color(0xFF6390F0));
    });

    test('should return correct color for electric type', () {
      expect(getPokemonTypeColor('electric'), const Color(0xFFF7D02C));
    });

    test('should return correct color for grass type', () {
      expect(getPokemonTypeColor('grass'), const Color(0xFF7AC74C));
    });

    test('should return correct color for psychic type', () {
      expect(getPokemonTypeColor('psychic'), const Color(0xFFF95587));
    });

    test('should return correct color for dragon type', () {
      expect(getPokemonTypeColor('dragon'), const Color(0xFF6F35FC));
    });

    test('should be case-insensitive', () {
      expect(getPokemonTypeColor('FIRE'), getPokemonTypeColor('fire'));
      expect(getPokemonTypeColor('Water'), getPokemonTypeColor('water'));
      expect(getPokemonTypeColor('ELECTRIC'), getPokemonTypeColor('electric'));
    });

    test('should return normal color as fallback for unknown type', () {
      expect(getPokemonTypeColor('unknown_type'), const Color(0xFFA8A77A));
    });

    test('should return normal color for empty string', () {
      expect(getPokemonTypeColor(''), const Color(0xFFA8A77A));
    });

    test('normal type returns correct color', () {
      expect(getPokemonTypeColor('normal'), const Color(0xFFA8A77A));
    });

    test('should return correct color for all 18 types', () {
      for (final entry in pokemonTypeColors.entries) {
        expect(getPokemonTypeColor(entry.key), entry.value,
            reason: 'Wrong color for type: ${entry.key}');
      }
    });
  });
}
