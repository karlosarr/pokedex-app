class PokemonModel {
  final int id;
  final String name;
  final int baseExperience;
  final int height;
  final int weight;
  final Map<String, dynamic> sprites;
  final List<dynamic> types;
  final List<dynamic> stats;

  PokemonModel({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.sprites,
    required this.types,
    required this.stats,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'],
      name: json['name'],
      baseExperience: json['base_experience'] ?? 0,
      height: json['height'],
      weight: json['weight'],
      sprites: json['sprites'],
      types: json['types'],
      stats: json['stats'],
    );
  }
}
