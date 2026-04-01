import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedexapp/core/errors/failures.dart';
import 'package:pokedexapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedexapp/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedexapp/features/pokemon/domain/usecases/get_pokemon_list.dart';

class MockPokemonRepository extends Mock implements PokemonRepository {}

void main() {
  late GetPokemonList useCase;
  late MockPokemonRepository mockRepository;

  setUp(() {
    mockRepository = MockPokemonRepository();
    useCase = GetPokemonList(mockRepository);
  });

  group('GetPokemonList UseCase', () {
    const tPokemonList = PaginatedPokemonList(
      count: 1,
      results: [
        Pokemon(
          id: 1,
          name: 'bulbasaur',
          baseExperience: 64,
          imageUrl: 'url',
          types: ['grass'],
          weight: 69,
          height: 7,
          stats: [],
        )
      ],
    );

    test('should return PaginatedPokemonList when the repository responds correctly', () async {
      when(() => mockRepository.getPokemonList(limit: 20, offset: 0)).thenAnswer((_) async => const Right(tPokemonList));

      final result = await useCase(GetPokemonListParams(limit: 20, offset: 0));

      expect(result, const Right(tPokemonList));
      verify(() => mockRepository.getPokemonList(limit: 20, offset: 0)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when the repository fails', () async {
      when(() => mockRepository.getPokemonList(limit: 20, offset: 0)).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(GetPokemonListParams(limit: 20, offset: 0));

      expect(result, const Left(ServerFailure()));
    });
  });
}
