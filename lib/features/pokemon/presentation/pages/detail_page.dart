import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/pokemon_providers.dart';

class DetailPage extends ConsumerWidget {
  final String id;

  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokemonDetailProvider(id));

    return Scaffold(
      body: pokemonAsync.when(
        data: (pokemon) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(pokemon.name.toUpperCase()),
                background: Hero(
                  tag: 'pokemon_${pokemon.id}',
                  child: CachedNetworkImage(
                    imageUrl: pokemon.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: pokemon.types
                          .map((t) => Chip(label: Text(t.toUpperCase())))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text('Base Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...pokemon.stats.map((stat) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(stat.name.toUpperCase()),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: stat.baseStat / 100,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(stat.baseStat.toString()),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
