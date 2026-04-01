import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonList implements UseCase<PaginatedPokemonList, GetPokemonListParams> {
  final PokemonRepository repository;

  GetPokemonList(this.repository);

  @override
  Future<Either<Failure, PaginatedPokemonList>> call(GetPokemonListParams params) async {
    return await repository.getPokemonList(limit: params.limit, offset: params.offset);
  }
}

class GetPokemonListParams {
  final int limit;
  final int offset;

  GetPokemonListParams({this.limit = 20, this.offset = 0});
}
