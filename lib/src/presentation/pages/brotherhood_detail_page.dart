import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../data/models/brotherhood_detail_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';

class BrotherhoodDetailPage extends StatelessWidget {
  const BrotherhoodDetailPage({
    super.key,
    required this.brotherhoodSlug,
    required this.title,
    required this.repository,
    required this.config,
    required this.favoritesController,
  });

  final String brotherhoodSlug;
  final String title;
  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ListenableBuilder(
            listenable: favoritesController,
            builder: (context, child) {
              final isFavorite = favoritesController.isFavorite(brotherhoodSlug);
              return IconButton(
                onPressed: () => favoritesController.toggle(brotherhoodSlug),
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? const Color(0xFFC9983E) : null,
                ),
              );
            },
          ),
        ],
      ),
      body: AppScaffoldBackground(
        child: FutureBuilder<BrotherhoodDetail>(
          future: repository.getBrotherhoodDetail(
            citySlug: config.citySlug,
            year: config.editionYear,
            brotherhoodSlug: brotherhoodSlug,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
                ),
              );
            }

            final detail = snapshot.data;
            if (detail == null) {
              return const Center(child: Text('Sin datos de hermandad.'));
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _Header(detail: detail),
                const SizedBox(height: 12),
                _Counters(detail: detail),
                const SizedBox(height: 12),
                if (detail.headquartersName.isNotEmpty || detail.headquartersAddress.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(
                        detail.headquartersName.isEmpty
                            ? 'Sede canónica'
                            : detail.headquartersName,
                      ),
                      subtitle: Text(
                        detail.headquartersAddress.isEmpty
                            ? 'Dirección no disponible'
                            : detail.headquartersAddress,
                      ),
                    ),
                  ),
                if (detail.history.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(detail.history),
                    ),
                  ),
                ],
                if (detail.newsTitles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Noticias',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  for (final title in detail.newsTitles.take(5))
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.article_outlined),
                        title: Text(title),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.detail});

  final BrotherhoodDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [parseHexColor(detail.colorHex), const Color(0xFF8B1E3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (detail.fullName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(detail.fullName, style: const TextStyle(color: Colors.white70)),
          ],
          const SizedBox(height: 8),
          Text(
            detail.foundationYear == null
                ? 'Fundación: no disponible'
                : 'Fundación: ${detail.foundationYear}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Counters extends StatelessWidget {
  const _Counters({required this.detail});

  final BrotherhoodDetail detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CounterItem(label: 'Titulares', value: detail.figuresCount),
        _CounterItem(label: 'Pasos', value: detail.pasosCount),
        _CounterItem(label: 'Bandas', value: detail.bandsCount),
        _CounterItem(label: 'Estrenos', value: detail.debutsCount),
      ],
    );
  }
}

class _CounterItem extends StatelessWidget {
  const _CounterItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
