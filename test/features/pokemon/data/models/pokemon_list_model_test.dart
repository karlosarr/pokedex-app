import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/features/pokemon/data/models/pokemon_list_model.dart';

void main() {
  group('PokemonListModel', () {
    final tJson = {
      'count': 1302,
      'next': 'https://pokeapi.co/api/v2/pokemon?offset=20&limit=20',
      'previous': null,
      'results': [
        {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
        {'name': 'ivysaur', 'url': 'https://pokeapi.co/api/v2/pokemon/2/'},
      ],
    };

    group('fromJson', () {
      test('should parse count correctly', () {
        final model = PokemonListModel.fromJson(tJson);
        expect(model.count, 1302);
      });

      test('should parse next URL correctly', () {
        final model = PokemonListModel.fromJson(tJson);
        expect(model.next, 'https://pokeapi.co/api/v2/pokemon?offset=20&limit=20');
      });

      test('should parse null previous correctly', () {
        final model = PokemonListModel.fromJson(tJson);
        expect(model.previous, isNull);
      });

      test('should parse results list correctly', () {
        final model = PokemonListModel.fromJson(tJson);
        expect(model.results.length, 2);
        expect(model.results[0].name, 'bulbasaur');
        expect(model.results[1].name, 'ivysaur');
      });

      test('should parse item URLs correctly', () {
        final model = PokemonListModel.fromJson(tJson);
        expect(model.results[0].url, 'https://pokeapi.co/api/v2/pokemon/1/');
      });
    });
  });

  group('PokemonListItemModel', () {
    test('should parse name and url from json', () {
      final item = PokemonListItemModel.fromJson({
        'name': 'charmander',
        'url': 'https://pokeapi.co/api/v2/pokemon/4/',
      });
      expect(item.name, 'charmander');
      expect(item.url, 'https://pokeapi.co/api/v2/pokemon/4/');
    });
  });
}
