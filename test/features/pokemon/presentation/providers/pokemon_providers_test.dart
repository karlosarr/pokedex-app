import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedexapp/core/errors/failures.dart';
import 'package:pokedexapp/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedexapp/features/pokemon/domain/usecases/get_pokemon.dart';
import 'package:pokedexapp/features/pokemon/domain/usecases/get_pokemon_list.dart';
import 'package:pokedexapp/features/pokemon/domain/usecases/get_pokemon_names.dart';
import 'package:pokedexapp/features/pokemon/presentation/providers/pokemon_providers.dart';

class MockGetPokemon extends Mock implements GetPokemon {}

class MockGetPokemonList extends Mock implements GetPokemonList {}

class MockGetPokemonNames extends Mock implements GetPokemonNames {}

const tPokemon = Pokemon(
  id: 25,
  name: 'pikachu',
  imageUrl: 'https://example.com/pikachu.png',
  types: ['electric'],
  weight: 60,
  height: 4,
  baseExperience: 112,
  stats: [],
);

const tPaginatedList = PaginatedPokemonList(
  count: 40,
  next: 'https://pokeapi.co/api/v2/pokemon?offset=20',
  previous: null,
  results: [tPokemon],
);

const tPaginatedListNoNext = PaginatedPokemonList(
  count: 1,
  next: null,
  previous: null,
  results: [tPokemon],
);

const tPage2 = PaginatedPokemonList(
  count: 40,
  next: null,
  previous: 'https://pokeapi.co/api/v2/pokemon?offset=0',
  results: [
    Pokemon(
      id: 1,
      name: 'bulbasaur',
      imageUrl: '',
      types: ['grass'],
      weight: 69,
      height: 7,
      baseExperience: 64,
      stats: [],
    ),
  ],
);

void main() {
  late MockGetPokemon mockGetPokemon;
  late MockGetPokemonList mockGetPokemonList;
  late MockGetPokemonNames mockGetPokemonNames;

  setUpAll(() {
    registerFallbackValue(GetPokemonParams(nameOrId: ''));
    registerFallbackValue(GetPokemonListParams());
  });

  setUp(() {
    mockGetPokemon = MockGetPokemon();
    mockGetPokemonList = MockGetPokemonList();
    mockGetPokemonNames = MockGetPokemonNames();

    GetIt.instance.registerSingleton<GetPokemon>(mockGetPokemon);
    GetIt.instance.registerSingleton<GetPokemonList>(mockGetPokemonList);
    GetIt.instance.registerSingleton<GetPokemonNames>(mockGetPokemonNames);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  // -------------------------------------------------------------------------
  // SearchQueryNotifier
  // -------------------------------------------------------------------------
  group('SearchQueryNotifier', () {
    test('initial state is empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchQueryProvider), '');
    });

    test('updateQuery changes the state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).updateQuery('pikachu');
      expect(container.read(searchQueryProvider), 'pikachu');
    });

    test('clear resets the state to empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).updateQuery('raichu');
      container.read(searchQueryProvider.notifier).clear();
      expect(container.read(searchQueryProvider), '');
    });

    test('updating query multiple times keeps the latest value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).updateQuery('bulba');
      container.read(searchQueryProvider.notifier).updateQuery('bulbasaur');
      expect(container.read(searchQueryProvider), 'bulbasaur');
    });
  });

  // -------------------------------------------------------------------------
  // PokemonListNotifier
  // -------------------------------------------------------------------------
  group('PokemonListNotifier', () {
    test('build loads the first page of pokemon', () async {
      when(() => mockGetPokemonList(any()))
          .thenAnswer((_) async => const Right(tPaginatedList));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(pokemonListNotifierProvider.future);

      expect(result, [tPokemon]);
      verify(() => mockGetPokemonList(any())).called(1);
    });

    test('build throws when use case returns failure', () async {
      when(() => mockGetPokemonList(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Error')));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await expectLater(
        container.read(pokemonListNotifierProvider.future),
        throwsA(isA<Exception>()),
      );
    });

    test('loadMore appends new pokemon to the list', () async {
      var callCount = 0;
      when(() => mockGetPokemonList(any())).thenAnswer((_) async {
        callCount++;
        return callCount == 1
            ? const Right(tPaginatedList)
            : const Right(tPage2);
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(pokemonListNotifierProvider.future);
      await container.read(pokemonListNotifierProvider.notifier).loadMore();

      final result = container.read(pokemonListNotifierProvider).requireValue;
      expect(result.length, 2); // 1 from page 1 + 1 from page 2
    });

    test('loadMore does nothing when there are no more pages', () async {
      when(() => mockGetPokemonList(any()))
          .thenAnswer((_) async => const Right(tPaginatedListNoNext));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(pokemonListNotifierProvider.future);

      // hasMore is false now, loadMore should be a no-op
      await container.read(pokemonListNotifierProvider.notifier).loadMore();

      // Only the initial build call
      verify(() => mockGetPokemonList(any())).called(1);
    });

    test('hasMore is true when next is non-null', () async {
      when(() => mockGetPokemonList(any()))
          .thenAnswer((_) async => const Right(tPaginatedList));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(pokemonListNotifierProvider.future);
      expect(
          container.read(pokemonListNotifierProvider.notifier).hasMore, isTrue);
    });

    test('hasMore is false when next is null', () async {
      when(() => mockGetPokemonList(any()))
          .thenAnswer((_) async => const Right(tPaginatedListNoNext));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(pokemonListNotifierProvider.future);
      expect(container.read(pokemonListNotifierProvider.notifier).hasMore,
          isFalse);
    });

    test('isLoadingMore is false after loading completes', () async {
      when(() => mockGetPokemonList(any()))
          .thenAnswer((_) async => const Right(tPaginatedList));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(pokemonListNotifierProvider.future);
      expect(
          container.read(pokemonListNotifierProvider.notifier).isLoadingMore,
          isFalse);
    });

    test('loadMore handles fetch error gracefully', () async {
      var callCount = 0;
      when(() => mockGetPokemonList(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) return const Right(tPaginatedList);
        return const Left(ServerFailure(message: 'Page 2 failed'));
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(pokemonListNotifierProvider.future);

      // Should not throw even if loadMore fails
      await container.read(pokemonListNotifierProvider.notifier).loadMore();

      // List should remain as-is from page 1
      final result = container.read(pokemonListNotifierProvider).requireValue;
      expect(result, [tPokemon]);
    });
  });

  // -------------------------------------------------------------------------
  // pokemonDetailProvider
  // -------------------------------------------------------------------------
  group('pokemonDetailProvider', () {
    test('should return Pokemon on success', () async {
      when(() => mockGetPokemon(any()))
          .thenAnswer((_) async => const Right(tPokemon));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result =
          await container.read(pokemonDetailProvider('pikachu').future);
      expect(result, tPokemon);
    });

  });

  // -------------------------------------------------------------------------
  // searchPokemonProvider
  // -------------------------------------------------------------------------
  group('searchPokemonProvider', () {
    test('should return null when query is empty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(searchPokemonProvider.future);
      expect(result, isNull);
    });

    test('should return Pokemon when query matches', () async {
      when(() => mockGetPokemon(any()))
          .thenAnswer((_) async => const Right(tPokemon));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).updateQuery('pikachu');

      final result = await container.read(searchPokemonProvider.future);
      expect(result, tPokemon);
    });

    test('should return null when use case returns failure', () async {
      when(() => mockGetPokemon(any()))
          .thenAnswer((_) async => const Left(ServerFailure()));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).updateQuery('unknown');

      final result = await container.read(searchPokemonProvider.future);
      expect(result, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // allPokemonNamesProvider
  // -------------------------------------------------------------------------
  group('allPokemonNamesProvider', () {
    test('should return list of names on success', () async {
      when(() => mockGetPokemonNames())
          .thenAnswer((_) async => const Right(['bulbasaur', 'ivysaur']));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(allPokemonNamesProvider.future);
      expect(result, ['bulbasaur', 'ivysaur']);
    });

    test('should return empty list when use case returns failure', () async {
      when(() => mockGetPokemonNames())
          .thenAnswer((_) async => const Left(ServerFailure()));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(allPokemonNamesProvider.future);
      expect(result, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // pokemonListProvider (backward-compat provider)
  // -------------------------------------------------------------------------
  group('pokemonListProvider', () {
    test('should return PaginatedPokemonList on success', () async {
      when(() => mockGetPokemonList(any()))
          .thenAnswer((_) async => const Right(tPaginatedList));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(pokemonListProvider.future);
      expect(result, tPaginatedList);
    });

    test('should throw when use case returns failure', () async {
      when(() => mockGetPokemonList(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Fail')));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Keep a listener to prevent autoDispose from kicking in during the test
      container.listen(pokemonListProvider, (prev, next) {});

      await expectLater(
        container.read(pokemonListProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
