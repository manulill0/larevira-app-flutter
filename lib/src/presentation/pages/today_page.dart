import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../data/models/brotherhood_model.dart';
import '../../data/models/day_models.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';
import 'day_detail_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;

  @override
  Widget build(BuildContext context) {
    final favoritesFuture = repository.getBrotherhoods(
      citySlug: config.citySlug,
      year: config.editionYear,
    );

    return AppScaffoldBackground(
      child: SafeArea(
        child: FutureBuilder<List<DayIndexItem>>(
          future: repository.getDays(
            citySlug: config.citySlug,
            year: config.editionYear,
            mode: config.mode,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
                baseUrl: config.baseUrl,
              );
            }

            final days = snapshot.data ?? const <DayIndexItem>[];
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'La Revira',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Text(
                      '${config.citySlug.toUpperCase()} ${config.editionYear} · Modo ${config.mode}',
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _HeroStatusCard(days: days),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                    child: ListenableBuilder(
                      listenable: favoritesController,
                      builder: (context, child) {
                        return FutureBuilder<List<BrotherhoodItem>>(
                          future: favoritesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState != ConnectionState.done ||
                                !snapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            final favoriteSlugs = favoritesController.all;
                            if (favoriteSlugs.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            final favorites = snapshot.data!
                                .where((item) => favoriteSlugs.contains(item.slug))
                                .toList(growable: false);
                            if (favorites.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tus favoritas',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final item in favorites)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: parseHexColor(item.colorHex)
                                              .withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 15,
                                              color: parseHexColor(item.colorHex),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(item.name),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final formatted = day.startsAt == null
                          ? 'Sin hora de inicio'
                          : DateFormat('EEE d MMM, HH:mm', 'es_ES').format(day.startsAt!);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF8B1E3F),
                              child: Icon(Icons.access_time, color: Colors.white),
                            ),
                            title: Text(day.name),
                            subtitle: Text('$formatted · ${day.processionEventsCount} cofradías'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => DayDetailPage(
                                    daySlug: day.slug,
                                    title: day.name,
                                    repository: repository,
                                    config: config,
                                    mode: config.mode,
                                    favoritesController: favoritesController,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard({required this.days});

  final List<DayIndexItem> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B1E3F), Color(0xFFB03A5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agenda de Semana Santa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${days.length} jornadas disponibles',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.baseUrl,
  });

  final String message;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No se pudo cargar la información.\nBase URL: $baseUrl\n$message',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
