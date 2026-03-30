import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedexapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedexapp/features/pokemon/presentation/pages/home_page.dart';
import 'package:pokedexapp/features/pokemon/presentation/providers/pokemon_providers.dart';

const _tPokemon = Pokemon(
  id: 25,
  name: 'pikachu',
  imageUrl: 'https://example.com/pikachu.png',
  types: ['electric'],
  weight: 60,
  height: 4,
  baseExperience: 112,
  stats: [],
);

// Stub notifier that returns a fixed list without touching GetIt
class _SuccessNotifier extends PokemonListNotifier {
  final List<Pokemon> pokemons;
  _SuccessNotifier(this.pokemons);

  @override
  Future<List<Pokemon>> build() async => pokemons;

  @override
  Future<void> loadMore() async {}
}

class _LoadingNotifier extends PokemonListNotifier {
  @override
  Future<List<Pokemon>> build() => Completer<List<Pokemon>>().future;
}

class _ErrorNotifier extends PokemonListNotifier {
  @override
  // StateError extends Error, which bypasses Riverpod's default retry logic
  Future<List<Pokemon>> build() => throw StateError('Load failed');
}

GoRouter _makeRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
            path: '/pokemon/:id',
            builder: (context, state) => const SizedBox()),
      ],
    );

Widget _buildWidget(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: _makeRouter()),
  );
}

// Direct wrapper without GoRouter — safe for tests that don't tap cards
Widget _buildDirect(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  testWidgets('shows AppBar title Pokédex', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pokédex'), findsOneWidget);
  });

  testWidgets('shows search field with hint text', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.widgetWithText(TextField, 'Buscar Pokémon...'), findsOneWidget);
  });

  testWidgets('shows loading indicator while list is loading', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider.overrideWith(_LoadingNotifier.new),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows pokemon name in grid card on success', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('#025'), findsOneWidget);
  });

  testWidgets('shows type chip in card', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Electric'), findsOneWidget);
  });

  testWidgets('shows error message when list fails to load', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider.overrideWith(_ErrorNotifier.new),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
    ]);
    addTearDown(container.dispose);

    // Use direct MaterialApp so GoRouter pump delay doesn't hide the error
    await tester.pumpWidget(_buildDirect(container));
    await tester.pump();

    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('shows search result when query is non-empty', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
      searchPokemonProvider.overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    container.read(searchQueryProvider.notifier).updateQuery('pikachu');

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pikachu'), findsOneWidget);
  });

  testWidgets('shows no-result message when search returns null',
      (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
      searchPokemonProvider.overrideWith((ref) async => null),
    ]);
    addTearDown(container.dispose);

    container.read(searchQueryProvider.notifier).updateQuery('xyz');

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pokémon no encontrado'), findsOneWidget);
  });

  testWidgets('clear button appears when query is non-empty', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
      searchPokemonProvider.overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    container.read(searchQueryProvider.notifier).updateQuery('pikachu');

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('clear button does not appear when query is empty',
      (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('tapping clear button clears the query', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
      searchPokemonProvider.overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    container.read(searchQueryProvider.notifier).updateQuery('pikachu');

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(container.read(searchQueryProvider), '');
  });

  testWidgets('shows multiple pokemon cards in the grid', (tester) async {
    const bulbasaur = Pokemon(
      id: 1,
      name: 'bulbasaur',
      imageUrl: '',
      types: ['grass'],
      weight: 69,
      height: 7,
      baseExperience: 64,
      stats: [],
    );
    final container = ProviderContainer(overrides: [
      pokemonListNotifierProvider
          .overrideWith(() => _SuccessNotifier([_tPokemon, bulbasaur])),
      allPokemonNamesProvider.overrideWith((ref) async => <String>[]),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
  });
}
