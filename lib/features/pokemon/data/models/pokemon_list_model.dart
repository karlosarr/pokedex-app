class PokemonListModel {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItemModel> results;

  PokemonListModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListModel.fromJson(Map<String, dynamic> json) {
    return PokemonListModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => PokemonListItemModel.fromJson(e))
          .toList(),
    );
  }
}

class PokemonListItemModel {
  final String name;
  final String url;

  PokemonListItemModel({required this.name, required this.url});

  factory PokemonListItemModel.fromJson(Map<String, dynamic> json) {
    return PokemonListItemModel(
      name: json['name'],
      url: json['url'],
    );
  }
}
