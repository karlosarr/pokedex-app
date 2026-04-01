import '../../domain/entities/pokemon.dart';
import 'pokemon_model.dart';

class PokemonMapper {
  static Pokemon fromModel(PokemonModel model) {
    return Pokemon(
      id: model.id,
      name: model.name,
      imageUrl: model.sprites['other']?['official-artwork']?['front_default'] ??
          model.sprites['front_default'] ??
          '',
      types: model.types
          .map((t) => t['type']['name'] as String)
          .toList(),
      weight: model.weight,
      height: model.height,
      baseExperience: model.baseExperience,
      stats: model.stats
          .map((s) => PokemonStat(
                name: s['stat']['name'] as String,
                baseStat: s['base_stat'] as int,
              ))
          .toList(),
    );
  }
}
