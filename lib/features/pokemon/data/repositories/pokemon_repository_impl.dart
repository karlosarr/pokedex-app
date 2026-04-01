import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_remote_datasource.dart';
import '../models/mappers.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;

  PokemonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Pokemon>> getPokemon(String nameOrId) async {
    try {
      final model = await remoteDataSource.getPokemon(nameOrId);
      return Right(PokemonMapper.fromModel(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedPokemonList>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final modelList = await remoteDataSource.getPokemonList(
        limit: limit,
        offset: offset,
      );

      final List<Pokemon> pokemons = [];
      for (var item in modelList.results) {
        try {
          final pokemonModel = await remoteDataSource.getPokemon(item.name);
          pokemons.add(PokemonMapper.fromModel(pokemonModel));
        } catch (e) {
          continue;
        }
      }

      return Right(PaginatedPokemonList(
        count: modelList.count,
        next: modelList.next,
        previous: modelList.previous,
        results: pokemons,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
