import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/pokemon_type_colors.dart';
import '../../domain/entities/pokemon.dart';
import '../providers/pokemon_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(pokemonListNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final allNamesAsync = ref.watch(allPokemonNamesProvider);
    final allNames = allNamesAsync.asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _buildAutocomplete(allNames, query),
          ),
          Expanded(
            child: query.isNotEmpty
                ? _buildSearchResults(query)
                : _buildPaginatedGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildAutocomplete(List<String> allNames, String currentQuery) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        final text = textEditingValue.text.trim().toLowerCase();
        if (text.length < 2) return const Iterable<String>.empty();
        return allNames
            .where((name) => name.toLowerCase().startsWith(text))
            .take(8);
      },
      onSelected: (selection) {
        _searchController.text = selection;
        ref.read(searchQueryProvider.notifier).updateQuery(selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _searchController.addListener(() {});
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Buscar Pokémon...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: currentQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      ref.read(searchQueryProvider.notifier).clear();
                    },
                  )
                : null,
          ),
          onSubmitted: (value) {
            final trimmed = value.trim().toLowerCase();
            if (trimmed.isNotEmpty) {
              ref.read(searchQueryProvider.notifier).updateQuery(trimmed);
            }
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF282B36),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(Icons.catching_pokemon, size: 20, color: Colors.redAccent),
                    title: Text(
                      _capitalize(option),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => onSelected(option),
                    dense: true,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(String query) {
    final searchResult = ref.watch(searchPokemonProvider);
    return searchResult.when(
      data: (pokemon) {
        if (pokemon == null) {
          return const Center(child: Text('Pokémon no encontrado'));
        }
        return _buildGrid([pokemon], showLoadingFooter: false);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildPaginatedGrid() {
    final listAsync = ref.watch(pokemonListNotifierProvider);
    return listAsync.when(
      data: (pokemons) => _buildGrid(pokemons, showLoadingFooter: true),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildGrid(List<Pokemon> pokemonList, {required bool showLoadingFooter}) {
    return GridView.builder(
      controller: showLoadingFooter ? _scrollController : null,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: pokemonList.length + (showLoadingFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == pokemonList.length) {
          final notifier = ref.read(pokemonListNotifierProvider.notifier);
          if (!notifier.hasMore) return const SizedBox.shrink();
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildPokemonCard(context, pokemonList[index]);
      },
    );
  }

  Widget _buildPokemonCard(BuildContext context, Pokemon pokemon) {
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first : 'normal';
    final cardColor = getPokemonTypeColor(primaryType);
    final darkColor = Color.fromARGB(
      255,
      ((cardColor.r * 255.0).round().clamp(0, 255) * 0.7).round(),
      ((cardColor.g * 255.0).round().clamp(0, 255) * 0.7).round(),
      ((cardColor.b * 255.0).round().clamp(0, 255) * 0.7).round(),
    );

    return GestureDetector(
      onTap: () => context.push('/pokemon/${pokemon.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cardColor, darkColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative pokeball watermark
            Positioned(
              right: -12,
              bottom: -12,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.catching_pokemon,
                  size: 90,
                  color: Colors.white,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Name
                  Text(
                    _capitalize(pokemon.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Type chips
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: pokemon.types
                        .map((type) => _buildTypeChip(type))
                        .toList(),
                  ),
                ],
              ),
            ),
            // Pokemon image
            Positioned(
              right: 4,
              bottom: 4,
              child: Hero(
                tag: 'pokemon_${pokemon.id}',
                child: CachedNetworkImage(
                  imageUrl: pokemon.imageUrl,
                  height: 72,
                  width: 72,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const SizedBox(
                    height: 72,
                    width: 72,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => const Icon(
                    Icons.catching_pokemon,
                    size: 56,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _capitalize(type),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
