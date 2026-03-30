import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedexapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedexapp/features/pokemon/presentation/pages/detail_page.dart';
import 'package:pokedexapp/features/pokemon/presentation/providers/pokemon_providers.dart';

const _tPokemon = Pokemon(
  id: 25,
  name: 'pikachu',
  imageUrl: 'https://example.com/pikachu.png',
  types: ['electric'],
  weight: 60,
  height: 4,
  baseExperience: 112,
  stats: [
    PokemonStat(name: 'hp', baseStat: 35),
    PokemonStat(name: 'attack', baseStat: 55),
    PokemonStat(name: 'defense', baseStat: 40),
    PokemonStat(name: 'special-attack', baseStat: 50),
    PokemonStat(name: 'special-defense', baseStat: 50),
    PokemonStat(name: 'speed', baseStat: 90),
  ],
);

Widget _buildWidget(String id, ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: DetailPage(id: id)),
  );
}

void main() {
  testWidgets('shows CircularProgressIndicator while loading', (tester) async {
    final completer = Completer<Pokemon>();
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('pikachu').overrideWith((ref) => completer.future),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('pikachu', container));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(_tPokemon);
  });

  testWidgets('shows pokemon name and id on success', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('pikachu').overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('pikachu', container));
    await tester.pumpAndSettle();

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('#025'), findsOneWidget);
  });

  testWidgets('shows type chip', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('pikachu').overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('pikachu', container));
    await tester.pumpAndSettle();

    expect(find.text('Electric'), findsOneWidget);
  });

  testWidgets('shows height, weight and base experience info cards',
      (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('pikachu').overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('pikachu', container));
    await tester.pumpAndSettle();

    expect(find.text('0.4 m'), findsOneWidget);
    expect(find.text('6.0 kg'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('Altura'), findsOneWidget);
    expect(find.text('Peso'), findsOneWidget);
    expect(find.text('Exp. Base'), findsOneWidget);
  });

  testWidgets('shows Estadísticas Base section header', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('pikachu').overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('pikachu', container));
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas Base'), findsOneWidget);
  });

  testWidgets('shows all stat labels and progress bars', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('pikachu').overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('pikachu', container));
    await tester.pumpAndSettle();

    expect(find.text('HP'), findsOneWidget);
    expect(find.text('ATK'), findsOneWidget);
    expect(find.text('DEF'), findsOneWidget);
    expect(find.text('Sp.ATK'), findsOneWidget);
    expect(find.text('Sp.DEF'), findsOneWidget);
    expect(find.text('SPD'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(6));
  });

  testWidgets('shows stat value numbers', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('pikachu').overrideWith((ref) async => _tPokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('pikachu', container));
    await tester.pumpAndSettle();

    expect(find.text('35'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
  });

  testWidgets('shows error text on failure', (tester) async {
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('unknown')
          .overrideWith((ref) async => throw Exception('Not found')),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('unknown', container));
    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('uses fallback label for unknown stat name', (tester) async {
    const pokemon = Pokemon(
      id: 1,
      name: 'bulbasaur',
      imageUrl: '',
      types: ['grass'],
      weight: 69,
      height: 7,
      baseExperience: 64,
      stats: [PokemonStat(name: 'custom-stat', baseStat: 77)],
    );
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('bulbasaur').overrideWith((ref) async => pokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('bulbasaur', container));
    await tester.pumpAndSettle();

    expect(find.text('CUSTOM-STAT'), findsOneWidget);
    expect(find.text('77'), findsOneWidget);
  });

  testWidgets('renders with no types — uses normal color fallback',
      (tester) async {
    const pokemon = Pokemon(
      id: 132,
      name: 'ditto',
      imageUrl: '',
      types: [],
      weight: 40,
      height: 3,
      baseExperience: 101,
      stats: [],
    );
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('ditto').overrideWith((ref) async => pokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('ditto', container));
    await tester.pumpAndSettle();

    expect(find.text('Ditto'), findsOneWidget);
    expect(find.text('#132'), findsOneWidget);
  });

  testWidgets('renders correctly with multiple types', (tester) async {
    const pokemon = Pokemon(
      id: 6,
      name: 'charizard',
      imageUrl: '',
      types: ['fire', 'flying'],
      weight: 905,
      height: 17,
      baseExperience: 240,
      stats: [],
    );
    final container = ProviderContainer(overrides: [
      pokemonDetailProvider('charizard').overrideWith((ref) async => pokemon),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildWidget('charizard', container));
    await tester.pumpAndSettle();

    expect(find.text('Fire'), findsOneWidget);
    expect(find.text('Flying'), findsOneWidget);
  });
}
