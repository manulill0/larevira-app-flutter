import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../data/models/brotherhood_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';
import 'brotherhood_detail_page.dart';

class BrotherhoodsPage extends StatefulWidget {
  const BrotherhoodsPage({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;

  @override
  State<BrotherhoodsPage> createState() => _BrotherhoodsPageState();
}

class _BrotherhoodsPageState extends State<BrotherhoodsPage> {
  late final Future<List<BrotherhoodItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getBrotherhoods(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hermandades',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
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

                  final brotherhoods = [...(snapshot.data ?? const <BrotherhoodItem>[])]
                    ..sort((a, b) {
                      final af = widget.favoritesController.isFavorite(a.slug);
                      final bf = widget.favoritesController.isFavorite(b.slug);
                      if (af == bf) {
                        return a.name.compareTo(b.name);
                      }
                      return af ? -1 : 1;
                    });
                  if (brotherhoods.isEmpty) {
                    return const Center(child: Text('No hay hermandades publicadas.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemBuilder: (context, index) {
                      final item = brotherhoods[index];
                      final isFavorite = widget.favoritesController.isFavorite(item.slug);
                      return Card(
                        child: ListTile(
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
                            onPressed: () => widget.favoritesController.toggle(item.slug),
                            icon: Icon(
                              isFavorite ? Icons.star : Icons.star_border,
                              color: isFavorite ? const Color(0xFFC9983E) : null,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BrotherhoodDetailPage(
                                  brotherhoodSlug: item.slug,
                                  title: item.name,
                                  repository: widget.repository,
                                  config: widget.config,
                                  favoritesController: widget.favoritesController,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemCount: brotherhoods.length,
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
