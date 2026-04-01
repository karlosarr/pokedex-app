import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/usecases/get_pokemon.dart';
import '../../domain/usecases/get_pokemon_list.dart';

final pokemonListProvider = FutureProvider.autoDispose<PaginatedPokemonList>((ref) async {
  final usecase = getIt<GetPokemonList>();
  final result = await usecase(GetPokemonListParams(limit: 20));
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

final pokemonDetailProvider = FutureProvider.family<Pokemon, String>((ref, nameOrId) async {
  final usecase = getIt<GetPokemon>();
  final result = await usecase(GetPokemonParams(nameOrId: nameOrId));
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final searchPokemonProvider = FutureProvider.autoDispose<Pokemon?>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return null;

  final usecase = getIt<GetPokemon>();
  final result = await usecase(GetPokemonParams(nameOrId: query));
  return result.fold(
    (failure) => null,
    (data) => data,
  );
});
