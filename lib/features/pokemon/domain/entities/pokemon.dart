import 'package:equatable/equatable.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int weight;
  final int height;
  final int baseExperience;
  final List<PokemonStat> stats;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.weight,
    required this.height,
    required this.baseExperience,
    required this.stats,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        types,
        weight,
        height,
        baseExperience,
        stats,
      ];
}

class PokemonStat extends Equatable {
  final String name;
  final int baseStat;

  const PokemonStat({required this.name, required this.baseStat});

  @override
  List<Object?> get props => [name, baseStat];
}

class PaginatedPokemonList extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<Pokemon> results;

  const PaginatedPokemonList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [count, next, previous, results];
}
