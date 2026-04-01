import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedexapp/core/errors/exceptions.dart';
import 'package:pokedexapp/core/errors/failures.dart';
import 'package:pokedexapp/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedexapp/features/pokemon/data/models/pokemon_list_model.dart';
import 'package:pokedexapp/features/pokemon/data/models/pokemon_model.dart';
import 'package:pokedexapp/features/pokemon/data/repositories/pokemon_repository_impl.dart';
import 'package:pokedexapp/features/pokemon/domain/entities/pokemon.dart';

class MockPokemonRemoteDataSource extends Mock
    implements PokemonRemoteDataSource {}

void main() {
  late PokemonRepositoryImpl repository;
  late MockPokemonRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockPokemonRemoteDataSource();
    repository = PokemonRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final tPokemonModel = PokemonModel(
    id: 25,
    name: 'pikachu',
    baseExperience: 112,
    height: 4,
    weight: 60,
    sprites: {
      'front_default': 'https://example.com/front.png',
      'other': {
        'official-artwork': {'front_default': 'https://example.com/artwork.png'}
      },
    },
    types: [
      {'type': {'name': 'electric'}}
    ],
    stats: [
      {'stat': {'name': 'hp'}, 'base_stat': 35},
    ],
  );

  final tListModel = PokemonListModel(
    count: 1302,
    next: 'https://pokeapi.co/api/v2/pokemon?offset=20&limit=20',
    previous: null,
    results: [
      PokemonListItemModel(
        name: 'pikachu',
        url: 'https://pokeapi.co/api/v2/pokemon/25/',
      ),
    ],
  );

  group('getPokemon', () {
    test('should return Pokemon entity on success', () async {
      when(() => mockDataSource.getPokemon('pikachu'))
          .thenAnswer((_) async => tPokemonModel);

      final result = await repository.getPokemon('pikachu');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (pokemon) {
          expect(pokemon.id, 25);
          expect(pokemon.name, 'pikachu');
          expect(pokemon.types, ['electric']);
          expect(pokemon.imageUrl, 'https://example.com/artwork.png');
        },
      );
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockDataSource.getPokemon(any()))
          .thenThrow(ServerException(message: 'Not Found'));

      final result = await repository.getPokemon('unknown');

      expect(result, Left(const ServerFailure(message: 'Not Found')));
    });

    test('should return ServerFailure on unexpected exception', () async {
      when(() => mockDataSource.getPokemon(any()))
          .thenThrow(Exception('Unexpected'));

      final result = await repository.getPokemon('pikachu');

      expect(result.isLeft(), true);
    });
  });

  group('getPokemonList', () {
    test('should return PaginatedPokemonList with fetched details', () async {
      when(() => mockDataSource.getPokemonList(limit: 20, offset: 0))
          .thenAnswer((_) async => tListModel);
      when(() => mockDataSource.getPokemon('pikachu'))
          .thenAnswer((_) async => tPokemonModel);

      final result = await repository.getPokemonList(limit: 20, offset: 0);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (list) {
          expect(list.count, 1302);
          expect(list.results.length, 1);
          expect(list.results[0].name, 'pikachu');
          expect(list.next, isNotNull);
        },
      );
    });

    test('should return ServerFailure when list fetch fails', () async {
      when(() => mockDataSource.getPokemonList(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenThrow(ServerException(message: 'Server Error'));

      final result = await repository.getPokemonList();

      expect(result.isLeft(), true);
    });

    test('should skip individual pokemon that fail and continue', () async {
      final listWith2 = PokemonListModel(
        count: 2,
        next: null,
        previous: null,
        results: [
          PokemonListItemModel(name: 'pikachu', url: ''),
          PokemonListItemModel(name: 'broken', url: ''),
        ],
      );
      when(() => mockDataSource.getPokemonList(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => listWith2);
      when(() => mockDataSource.getPokemon('pikachu'))
          .thenAnswer((_) async => tPokemonModel);
      when(() => mockDataSource.getPokemon('broken'))
          .thenThrow(ServerException(message: 'Not Found'));

      final result = await repository.getPokemonList();

      result.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list.results.length, 1),
      );
    });
  });

  group('getPokemonNames', () {
    test('should return list of names extracted from list model', () async {
      final bigList = PokemonListModel(
        count: 3,
        next: null,
        previous: null,
        results: [
          PokemonListItemModel(name: 'bulbasaur', url: ''),
          PokemonListItemModel(name: 'ivysaur', url: ''),
          PokemonListItemModel(name: 'venusaur', url: ''),
        ],
      );
      when(() => mockDataSource.getPokemonList(
            limit: 1302,
            offset: 0,
          )).thenAnswer((_) async => bigList);

      final result = await repository.getPokemonNames();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (names) => expect(names, ['bulbasaur', 'ivysaur', 'venusaur']),
      );
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockDataSource.getPokemonList(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenThrow(ServerException(message: 'Error'));

      final result = await repository.getPokemonNames();

      expect(result.isLeft(), true);
    });

    test('should return empty list when no pokemon exist', () async {
      when(() => mockDataSource.getPokemonList(
            limit: 1302,
            offset: 0,
          )).thenAnswer((_) async => PokemonListModel(
            count: 0,
            next: null,
            previous: null,
            results: [],
          ));

      final result = await repository.getPokemonNames();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (names) => expect(names, isEmpty),
      );
    });
  });

  group('PaginatedPokemonList entity', () {
    test('should correctly report hasNext when next is not null', () {
      const list = PaginatedPokemonList(
        count: 100,
        next: 'https://pokeapi.co/api/v2/pokemon?offset=20',
        results: [],
      );
      expect(list.next, isNotNull);
    });

    test('should correctly report no next page when next is null', () {
      const list = PaginatedPokemonList(count: 5, next: null, results: []);
      expect(list.next, isNull);
    });
  });
}
