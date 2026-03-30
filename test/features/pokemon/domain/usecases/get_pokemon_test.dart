import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedexapp/core/errors/failures.dart';
import 'package:pokedexapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedexapp/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedexapp/features/pokemon/domain/usecases/get_pokemon.dart';

class MockPokemonRepository extends Mock implements PokemonRepository {}

void main() {
  late GetPokemon useCase;
  late MockPokemonRepository mockRepository;

  setUp(() {
    mockRepository = MockPokemonRepository();
    useCase = GetPokemon(mockRepository);
  });

  group('GetPokemon UseCase', () {
    const tName = 'pikachu';
    const tPokemon = Pokemon(
      id: 25,
      name: tName,
      baseExperience: 112,
      imageUrl: 'url',
      types: ['electric'],
      weight: 60,
      height: 4,
      stats: [],
    );

    test('should return Pokemon when the repository responds correctly', () async {
      when(() => mockRepository.getPokemon(tName)).thenAnswer((_) async => const Right(tPokemon));

      final result = await useCase(GetPokemonParams(nameOrId: tName));

      expect(result, const Right(tPokemon));
      verify(() => mockRepository.getPokemon(tName)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when the repository fails', () async {
      when(() => mockRepository.getPokemon(tName)).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(GetPokemonParams(nameOrId: tName));

      expect(result, const Left(ServerFailure()));
    });
  });
}
