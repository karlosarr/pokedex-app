import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/features/pokemon/domain/entities/pokemon.dart';

void main() {
  const tPokemon = Pokemon(
    id: 25,
    name: 'pikachu',
    imageUrl: 'https://example.com/pikachu.png',
    types: ['electric'],
    weight: 60,
    height: 4,
    baseExperience: 112,
    stats: [
      PokemonStat(name: 'hp', baseStat: 35),
      PokemonStat(name: 'attack', baseStat: 55),
    ],
  );

  group('Pokemon', () {
    test('should expose all fields correctly', () {
      expect(tPokemon.id, 25);
      expect(tPokemon.name, 'pikachu');
      expect(tPokemon.imageUrl, 'https://example.com/pikachu.png');
      expect(tPokemon.types, ['electric']);
      expect(tPokemon.weight, 60);
      expect(tPokemon.height, 4);
      expect(tPokemon.baseExperience, 112);
      expect(tPokemon.stats.length, 2);
    });

    test('two Pokemon with identical fields should be equal', () {
      const other = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        weight: 60,
        height: 4,
        baseExperience: 112,
        stats: [
          PokemonStat(name: 'hp', baseStat: 35),
          PokemonStat(name: 'attack', baseStat: 55),
        ],
      );
      expect(tPokemon, other);
    });

    test('two Pokemon with different ids should not be equal', () {
      const other = Pokemon(
        id: 1,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        weight: 60,
        height: 4,
        baseExperience: 112,
        stats: [],
      );
      expect(tPokemon, isNot(other));
    });

    test('props should include all fields', () {
      expect(tPokemon.props, [
        25,
        'pikachu',
        'https://example.com/pikachu.png',
        ['electric'],
        60,
        4,
        112,
        const [PokemonStat(name: 'hp', baseStat: 35), PokemonStat(name: 'attack', baseStat: 55)],
      ]);
    });

    test('should support dual types', () {
      const dualType = Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: '',
        types: ['grass', 'poison'],
        weight: 69,
        height: 7,
        baseExperience: 64,
        stats: [],
      );
      expect(dualType.types, ['grass', 'poison']);
    });
  });

  group('PokemonStat', () {
    const tStat = PokemonStat(name: 'hp', baseStat: 35);

    test('should expose name and baseStat correctly', () {
      expect(tStat.name, 'hp');
      expect(tStat.baseStat, 35);
    });

    test('two stats with same values should be equal', () {
      expect(tStat, const PokemonStat(name: 'hp', baseStat: 35));
    });

    test('two stats with different values should not be equal', () {
      expect(tStat, isNot(const PokemonStat(name: 'attack', baseStat: 55)));
    });

    test('props should contain name and baseStat', () {
      expect(tStat.props, ['hp', 35]);
    });
  });

  group('PaginatedPokemonList', () {
    const tList = PaginatedPokemonList(
      count: 1302,
      next: 'https://pokeapi.co/api/v2/pokemon?offset=20',
      previous: null,
      results: [],
    );

    test('should expose all fields correctly', () {
      expect(tList.count, 1302);
      expect(tList.next, 'https://pokeapi.co/api/v2/pokemon?offset=20');
      expect(tList.previous, isNull);
      expect(tList.results, isEmpty);
    });

    test('two lists with identical fields should be equal', () {
      const other = PaginatedPokemonList(
        count: 1302,
        next: 'https://pokeapi.co/api/v2/pokemon?offset=20',
        previous: null,
        results: [],
      );
      expect(tList, other);
    });

    test('should report next page available when next is non-null', () {
      expect(tList.next, isNotNull);
    });

    test('should report no next page when next is null', () {
      const noNext = PaginatedPokemonList(count: 5, next: null, results: []);
      expect(noNext.next, isNull);
    });

    test('props should include all fields', () {
      expect(tList.props, [
        1302,
        'https://pokeapi.co/api/v2/pokemon?offset=20',
        null,
        <Pokemon>[],
      ]);
    });

    test('should hold results correctly', () {
      const withResults = PaginatedPokemonList(
        count: 1,
        results: [tPokemon],
      );
      expect(withResults.results, [tPokemon]);
      expect(withResults.results.first.name, 'pikachu');
    });
  });
}
