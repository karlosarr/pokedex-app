import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemon implements UseCase<Pokemon, GetPokemonParams> {
  final PokemonRepository repository;

  GetPokemon(this.repository);

  @override
  Future<Either<Failure, Pokemon>> call(GetPokemonParams params) async {
    return await repository.getPokemon(params.nameOrId);
  }
}

class GetPokemonParams {
  final String nameOrId;

  GetPokemonParams({required this.nameOrId});
}
