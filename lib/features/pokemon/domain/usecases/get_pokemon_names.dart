import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonNames {
  final PokemonRepository repository;

  GetPokemonNames(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getPokemonNames();
  }
}
