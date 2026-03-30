import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/usecases/get_pokemon.dart';
import '../../domain/usecases/get_pokemon_list.dart';
import '../../domain/usecases/get_pokemon_names.dart';

// --- Paginated list (infinite scroll) ---

class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  static const int _pageSize = 20;
  int _offset = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  Future<List<Pokemon>> build() async {
    _offset = 0;
    _hasMore = true;
    _loadingMore = false;
    return await _fetchPage(0);
  }

  Future<List<Pokemon>> _fetchPage(int offset) async {
    final usecase = getIt<GetPokemonList>();
    final result = await usecase(GetPokemonListParams(limit: _pageSize, offset: offset));
    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) {
        _hasMore = data.next != null;
        return data.results;
      },
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.asData?.value;
    if (current == null) return;
    _loadingMore = true;
    _offset += _pageSize;
    try {
      final newItems = await _fetchPage(_offset);
      state = AsyncData([...current, ...newItems]);
    } catch (_) {
      _offset -= _pageSize;
    } finally {
      _loadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loadingMore;
}

final pokemonListNotifierProvider =
    AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
  PokemonListNotifier.new,
);

// Keep the old provider for backward compatibility
final pokemonListProvider = FutureProvider.autoDispose<PaginatedPokemonList>((ref) async {
  final usecase = getIt<GetPokemonList>();
  final result = await usecase(GetPokemonListParams(limit: 20));
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

// --- Pokemon detail ---

final pokemonDetailProvider = FutureProvider.family<Pokemon, String>((ref, nameOrId) async {
  final usecase = getIt<GetPokemon>();
  final result = await usecase(GetPokemonParams(nameOrId: nameOrId));
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

// --- Search ---

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
  void clear() => state = '';
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

// --- Autocomplete names ---

final allPokemonNamesProvider = FutureProvider<List<String>>((ref) async {
  final usecase = getIt<GetPokemonNames>();
  final result = await usecase();
  return result.fold(
    (failure) => <String>[],
    (names) => names,
  );
});
