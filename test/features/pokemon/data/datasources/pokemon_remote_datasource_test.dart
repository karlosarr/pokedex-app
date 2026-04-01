import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedexapp/core/errors/exceptions.dart';
import 'package:pokedexapp/features/pokemon/data/datasources/pokemon_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

RequestOptions _opts() => RequestOptions(path: '');

void main() {
  late PokemonRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = PokemonRemoteDataSourceImpl(dio: mockDio);
  });

  final tPokemonJson = {
    'id': 25,
    'name': 'pikachu',
    'base_experience': 112,
    'height': 4,
    'weight': 60,
    'sprites': {
      'front_default': 'https://example.com/pikachu.png',
      'other': {
        'official-artwork': {'front_default': 'https://example.com/artwork.png'}
      },
    },
    'types': [
      {'type': {'name': 'electric'}}
    ],
    'stats': [
      {'base_stat': 35, 'stat': {'name': 'hp'}},
    ],
  };

  final tListJson = {
    'count': 1302,
    'next': 'https://pokeapi.co/api/v2/pokemon?offset=20&limit=20',
    'previous': null,
    'results': [
      {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
    ],
  };

  group('getPokemon', () {
    test('should return PokemonModel on successful response', () async {
      when(() => mockDio.get('pokemon/pikachu')).thenAnswer(
        (_) async => Response(
          data: tPokemonJson,
          statusCode: 200,
          requestOptions: _opts(),
        ),
      );

      final result = await dataSource.getPokemon('pikachu');

      expect(result.id, 25);
      expect(result.name, 'pikachu');
      expect(result.baseExperience, 112);
    });

    test('should call endpoint with lowercased name', () async {
      when(() => mockDio.get('pokemon/pikachu')).thenAnswer(
        (_) async => Response(
          data: tPokemonJson,
          statusCode: 200,
          requestOptions: _opts(),
        ),
      );

      await dataSource.getPokemon('PIKACHU');

      verify(() => mockDio.get('pokemon/pikachu')).called(1);
    });

    test('should throw ServerException on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: _opts(),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => dataSource.getPokemon('pikachu'),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on 404 response', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: _opts(),
          response: Response(statusCode: 404, requestOptions: _opts()),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.getPokemon('unknown'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPokemonList', () {
    test('should return PokemonListModel on successful response', () async {
      when(() => mockDio.get(
            'pokemon',
            queryParameters: {'limit': 20, 'offset': 0},
          )).thenAnswer(
        (_) async => Response(
          data: tListJson,
          statusCode: 200,
          requestOptions: _opts(),
        ),
      );

      final result = await dataSource.getPokemonList(limit: 20, offset: 0);

      expect(result.count, 1302);
      expect(result.results.length, 1);
      expect(result.results[0].name, 'bulbasaur');
    });

    test('should pass limit and offset as query parameters', () async {
      when(() => mockDio.get(
            'pokemon',
            queryParameters: {'limit': 10, 'offset': 20},
          )).thenAnswer(
        (_) async => Response(
          data: tListJson,
          statusCode: 200,
          requestOptions: _opts(),
        ),
      );

      await dataSource.getPokemonList(limit: 10, offset: 20);

      verify(() => mockDio.get(
            'pokemon',
            queryParameters: {'limit': 10, 'offset': 20},
          )).called(1);
    });

    test('should throw ServerException on DioException', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
        requestOptions: _opts(),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => dataSource.getPokemonList(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
