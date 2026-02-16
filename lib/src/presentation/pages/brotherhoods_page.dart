import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../data/models/brotherhood_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';
import '../widgets/card_list_tile.dart';
import 'brotherhood_detail_page.dart';

class BrotherhoodsPage extends StatefulWidget {
  const BrotherhoodsPage({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.simulatedClockController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final SimulatedClockController simulatedClockController;

  @override
  State<BrotherhoodsPage> createState() => _BrotherhoodsPageState();
}

class _BrotherhoodsPageState extends State<BrotherhoodsPage> {
  late Future<List<BrotherhoodItem>> _future;
  bool _syncing = false;
  String? _selectedBrotherhoodSlug;

  @override
  void initState() {
    super.initState();
    _future = _loadLocal();
  }

  Future<List<BrotherhoodItem>> _loadLocal() {
    return widget.repository.getBrotherhoods(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
    );
  }

  Future<void> _refresh() async {
    if (_syncing) {
      return;
    }
    setState(() => _syncing = true);
    try {
      await widget.repository.syncBrotherhoods(
        citySlug: widget.config.citySlug,
        year: widget.config.editionYear,
      );
      setState(() {
        _future = _loadLocal();
      });
      await _future;
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  BrotherhoodItem? _selectedFor(List<BrotherhoodItem> brotherhoods) {
    if (brotherhoods.isEmpty) {
      return null;
    }
    final slug = _selectedBrotherhoodSlug;
    if (slug == null) {
      return brotherhoods.first;
    }
    for (final item in brotherhoods) {
      if (item.slug == slug) {
        return item;
      }
    }
    return brotherhoods.first;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Hermandades',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: _syncing ? null : () => _refresh(),
                    icon: _syncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.favoritesController,
                builder: (context, child) {
                  return FutureBuilder<List<BrotherhoodItem>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }

                      final brotherhoods =
                          [...(snapshot.data ?? const <BrotherhoodItem>[])]
                            ..sort((a, b) {
                              final af = widget.favoritesController.isFavorite(
                                a.slug,
                              );
                              final bf = widget.favoritesController.isFavorite(
                                b.slug,
                              );
                              if (af == bf) {
                                return a.name.compareTo(b.name);
                              }
                              return af ? -1 : 1;
                            });

                      if (brotherhoods.isEmpty) {
                        return const Center(
                          child: Text('No hay hermandades publicadas.'),
                        );
                      }

                      final media = MediaQuery.of(context);
                      final isTabletLandscape =
                          media.orientation == Orientation.landscape &&
                          media.size.width >= 1000 &&
                          media.size.height >= 600;
                      final selected = _selectedFor(brotherhoods);

                      if (isTabletLandscape) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 380,
                              child: RefreshIndicator(
                                onRefresh: _refresh,
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    12,
                                    24,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = brotherhoods[index];
                                    final isFavorite = widget
                                        .favoritesController
                                        .isFavorite(item.slug);
                                    return _BrotherhoodTile(
                                      item: item,
                                      isFavorite: isFavorite,
                                      isSelected: item.slug == selected?.slug,
                                      onToggleFavorite: () => widget
                                          .favoritesController
                                          .toggle(item.slug),
                                      onTap: () {
                                        setState(() {
                                          _selectedBrotherhoodSlug = item.slug;
                                        });
                                      },
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 8),
                                  itemCount: brotherhoods.length,
                                ),
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  4,
                                  20,
                                  24,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: selected == null
                                      ? const Center(
                                          child: Text(
                                            'Selecciona una hermandad.',
                                          ),
                                        )
                                      : BrotherhoodDetailPage(
                                          brotherhoodSlug: selected.slug,
                                          title: selected.name,
                                          repository: widget.repository,
                                          config: widget.config,
                                          favoritesController:
                                              widget.favoritesController,
                                          simulatedClockController:
                                              widget.simulatedClockController,
                                          embedded: true,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemBuilder: (context, index) {
                            final item = brotherhoods[index];
                            final isFavorite = widget.favoritesController
                                .isFavorite(item.slug);
                            return _BrotherhoodTile(
                              item: item,
                              isFavorite: isFavorite,
                              isSelected: false,
                              onToggleFavorite: () =>
                                  widget.favoritesController.toggle(item.slug),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => BrotherhoodDetailPage(
                                      brotherhoodSlug: item.slug,
                                      title: item.name,
                                      repository: widget.repository,
                                      config: widget.config,
                                      favoritesController:
                                          widget.favoritesController,
                                      simulatedClockController:
                                          widget.simulatedClockController,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemCount: brotherhoods.length,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrotherhoodTile extends StatelessWidget {
  const _BrotherhoodTile({
    required this.item,
    required this.isFavorite,
    required this.isSelected,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final BrotherhoodItem item;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CardListTile(
      color: isSelected ? const Color(0xFFFFF4DB) : null,
      selected: isSelected,
      leading: CircleAvatar(
        backgroundColor: parseHexColor(item.colorHex),
        child: const Icon(Icons.church, color: Colors.white),
      ),
      title: Text(item.name),
      subtitle: Text(
        item.fullName.isEmpty ? item.slug : item.fullName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: onToggleFavorite,
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? const Color(0xFFC9983E) : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
