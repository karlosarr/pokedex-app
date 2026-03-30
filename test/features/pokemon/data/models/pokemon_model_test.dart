import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/features/pokemon/data/models/pokemon_model.dart';

void main() {
  group('PokemonModel', () {
    final tJson = {
      'id': 25,
      'name': 'pikachu',
      'base_experience': 112,
      'height': 4,
      'weight': 60,
      'sprites': {
        'front_default': 'https://example.com/pikachu.png',
        'other': {
          'official-artwork': {
            'front_default': 'https://example.com/pikachu-artwork.png',
          }
        }
      },
      'types': [
        {
          'slot': 1,
          'type': {'name': 'electric', 'url': 'https://pokeapi.co/api/v2/type/13/'}
        }
      ],
      'stats': [
        {
          'base_stat': 35,
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'}
        },
        {
          'base_stat': 55,
          'effort': 0,
          'stat': {'name': 'attack', 'url': 'https://pokeapi.co/api/v2/stat/2/'}
        },
      ],
    };

    group('fromJson', () {
      test('should parse id correctly', () {
        final model = PokemonModel.fromJson(tJson);
        expect(model.id, 25);
      });

      test('should parse name correctly', () {
        final model = PokemonModel.fromJson(tJson);
        expect(model.name, 'pikachu');
      });

      test('should parse base_experience correctly', () {
        final model = PokemonModel.fromJson(tJson);
        expect(model.baseExperience, 112);
      });

      test('should parse height and weight correctly', () {
        final model = PokemonModel.fromJson(tJson);
        expect(model.height, 4);
        expect(model.weight, 60);
      });

      test('should parse sprites correctly', () {
        final model = PokemonModel.fromJson(tJson);
        expect(model.sprites['front_default'], 'https://example.com/pikachu.png');
      });

      test('should parse types list correctly', () {
        final model = PokemonModel.fromJson(tJson);
        expect(model.types.length, 1);
        expect(model.types[0]['type']['name'], 'electric');
      });

      test('should parse stats list correctly', () {
        final model = PokemonModel.fromJson(tJson);
        expect(model.stats.length, 2);
        expect(model.stats[0]['base_stat'], 35);
        expect(model.stats[0]['stat']['name'], 'hp');
      });

      test('should default base_experience to 0 when null', () {
        final jsonWithNullExp = Map<String, dynamic>.from(tJson)
          ..['base_experience'] = null;
        final model = PokemonModel.fromJson(jsonWithNullExp);
        expect(model.baseExperience, 0);
      });
    });
  });
}
