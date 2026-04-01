import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/pokemon_type_colors.dart';
import '../providers/pokemon_providers.dart';
import '../../domain/entities/pokemon.dart';

class DetailPage extends ConsumerWidget {
  final String id;

  const DetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokemonDetailProvider(id));

    return pokemonAsync.when(
      data: (pokemon) {
        final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first : 'normal';
        final headerColor = getPokemonTypeColor(primaryType);
        final darkHeaderColor = Color.fromARGB(
          255,
          ((headerColor.r * 255.0).round().clamp(0, 255) * 0.75).round(),
          ((headerColor.g * 255.0).round().clamp(0, 255) * 0.75).round(),
          ((headerColor.b * 255.0).round().clamp(0, 255) * 0.75).round(),
        );

        return Scaffold(
          backgroundColor: const Color(0xFF14161C),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: headerColor,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [headerColor, darkHeaderColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Pokeball watermark
                        Positioned(
                          right: -30,
                          top: -20,
                          child: Opacity(
                            opacity: 0.15,
                            child: Icon(
                              Icons.catching_pokemon,
                              size: 220,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Info
                        Positioned(
                          left: 16,
                          bottom: 90,
                          right: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${pokemon.id.toString().padLeft(3, '0')}',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _capitalize(pokemon.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: pokemon.types
                                    .map((t) => _typeChip(t))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        // Pokemon image
                        Positioned(
                          right: 8,
                          bottom: 16,
                          child: Hero(
                            tag: 'pokemon_${pokemon.id}',
                            child: CachedNetworkImage(
                              imageUrl: pokemon.imageUrl,
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,
                              errorWidget: (_, _, _) => const Icon(
                                Icons.catching_pokemon,
                                size: 100,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info row
                      Row(
                        children: [
                          _infoCard(
                            context,
                            icon: Icons.straighten,
                            label: 'Altura',
                            value: '${(pokemon.height / 10).toStringAsFixed(1)} m',
                            color: headerColor,
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            context,
                            icon: Icons.monitor_weight,
                            label: 'Peso',
                            value: '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
                            color: headerColor,
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            context,
                            icon: Icons.star,
                            label: 'Exp. Base',
                            value: pokemon.baseExperience.toString(),
                            color: headerColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Stats
                      Text(
                        'Estadísticas Base',
                        style: TextStyle(
                          color: headerColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...pokemon.stats.map((stat) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildStatRow(stat, headerColor),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF14161C),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: const Color(0xFF14161C),
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatRow(PokemonStat stat, Color accentColor) {
    final maxStat = 255.0;
    final statNames = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'Sp.ATK',
      'special-defense': 'Sp.DEF',
      'speed': 'SPD',
    };
    final label = statNames[stat.name] ?? stat.name.toUpperCase();
    final ratio = (stat.baseStat / maxStat).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            stat.baseStat.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _typeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _capitalize(type),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E212B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
