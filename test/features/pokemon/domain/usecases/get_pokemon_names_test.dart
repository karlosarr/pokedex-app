import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedexapp/core/errors/failures.dart';
import 'package:pokedexapp/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedexapp/features/pokemon/domain/usecases/get_pokemon_names.dart';

class MockPokemonRepository extends Mock implements PokemonRepository {}

void main() {
  late GetPokemonNames useCase;
  late MockPokemonRepository mockRepository;

  setUp(() {
    mockRepository = MockPokemonRepository();
    useCase = GetPokemonNames(mockRepository);
  });

  group('GetPokemonNames UseCase', () {
    const tNames = ['bulbasaur', 'ivysaur', 'venusaur'];

    test('should return a list of names when repository responds correctly', () async {
      when(() => mockRepository.getPokemonNames())
          .thenAnswer((_) async => const Right(tNames));

      final result = await useCase();

      expect(result, const Right(tNames));
      verify(() => mockRepository.getPokemonNames()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      when(() => mockRepository.getPokemonNames())
          .thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase();

      expect(result, const Left(ServerFailure()));
      verify(() => mockRepository.getPokemonNames()).called(1);
    });

    test('should return an empty list when repository returns empty', () async {
      when(() => mockRepository.getPokemonNames())
          .thenAnswer((_) async => const Right([]));

      final result = await useCase();

      expect(result, const Right(<String>[]));
    });
  });
}
