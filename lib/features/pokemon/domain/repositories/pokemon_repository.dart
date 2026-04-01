import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pokemon.dart';

abstract class PokemonRepository {
  Future<Either<Failure, Pokemon>> getPokemon(String nameOrId);
  Future<Either<Failure, PaginatedPokemonList>> getPokemonList({int limit = 20, int offset = 0});
}
