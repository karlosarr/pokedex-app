import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/features/pokemon/data/models/mappers.dart';
import 'package:pokedexapp/features/pokemon/data/models/pokemon_model.dart';
import 'package:pokedexapp/features/pokemon/domain/entities/pokemon.dart';

void main() {
  group('PokemonMapper', () {
    final tModel = PokemonModel(
      id: 25,
      name: 'pikachu',
      baseExperience: 112,
      height: 4,
      weight: 60,
      sprites: {
        'front_default': 'https://example.com/front.png',
        'other': {
          'official-artwork': {
            'front_default': 'https://example.com/official.png',
          }
        }
      },
      types: [
        {'type': {'name': 'electric'}}
      ],
      stats: [
        {'stat': {'name': 'hp'}, 'base_stat': 35},
        {'stat': {'name': 'attack'}, 'base_stat': 55},
      ],
    );

    test('should map id correctly', () {
      final pokemon = PokemonMapper.fromModel(tModel);
      expect(pokemon.id, 25);
    });

    test('should map name correctly', () {
      final pokemon = PokemonMapper.fromModel(tModel);
      expect(pokemon.name, 'pikachu');
    });

    test('should prefer official-artwork URL for imageUrl', () {
      final pokemon = PokemonMapper.fromModel(tModel);
      expect(pokemon.imageUrl, 'https://example.com/official.png');
    });

    test('should fallback to front_default when official-artwork is absent', () {
      final modelWithoutArtwork = PokemonModel(
        id: 1,
        name: 'bulbasaur',
        baseExperience: 64,
        height: 7,
        weight: 69,
        sprites: {'front_default': 'https://example.com/front.png'},
        types: [
          {'type': {'name': 'grass'}}
        ],
        stats: [],
      );
      final pokemon = PokemonMapper.fromModel(modelWithoutArtwork);
      expect(pokemon.imageUrl, 'https://example.com/front.png');
    });

    test('should fallback to empty string when both sprites are absent', () {
      final modelNoSprites = PokemonModel(
        id: 1,
        name: 'missingno',
        baseExperience: 0,
        height: 0,
        weight: 0,
        sprites: {},
        types: [],
        stats: [],
      );
      final pokemon = PokemonMapper.fromModel(modelNoSprites);
      expect(pokemon.imageUrl, '');
    });

    test('should map types correctly', () {
      final pokemon = PokemonMapper.fromModel(tModel);
      expect(pokemon.types, ['electric']);
    });

    test('should map multiple types correctly', () {
      final dualTypeModel = PokemonModel(
        id: 1,
        name: 'bulbasaur',
        baseExperience: 64,
        height: 7,
        weight: 69,
        sprites: {},
        types: [
          {'type': {'name': 'grass'}},
          {'type': {'name': 'poison'}},
        ],
        stats: [],
      );
      final pokemon = PokemonMapper.fromModel(dualTypeModel);
      expect(pokemon.types, ['grass', 'poison']);
    });

    test('should map stats correctly', () {
      final pokemon = PokemonMapper.fromModel(tModel);
      expect(pokemon.stats.length, 2);
      expect(pokemon.stats[0], const PokemonStat(name: 'hp', baseStat: 35));
      expect(pokemon.stats[1], const PokemonStat(name: 'attack', baseStat: 55));
    });

    test('should map height, weight and baseExperience correctly', () {
      final pokemon = PokemonMapper.fromModel(tModel);
      expect(pokemon.height, 4);
      expect(pokemon.weight, 60);
      expect(pokemon.baseExperience, 112);
    });

    test('should return a Pokemon entity', () {
      final result = PokemonMapper.fromModel(tModel);
      expect(result, isA<Pokemon>());
    });
  });
}
