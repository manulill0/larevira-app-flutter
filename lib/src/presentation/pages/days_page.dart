import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../data/models/day_models.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../widgets/app_scaffold_background.dart';
import 'day_detail_page.dart';

class DaysPage extends StatefulWidget {
  const DaysPage({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;

  @override
  State<DaysPage> createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {
  late String _mode = widget.config.mode;

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Jornadas',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      const Spacer(),
                      ListenableBuilder(
                        listenable: widget.favoritesController,
                        builder: (context, child) {
                          return Chip(
                            avatar: const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFF8B1E3F),
                            ),
                            label: Text('${widget.favoritesController.all.length} favoritas'),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('All')),
                      ButtonSegment(value: 'live', label: Text('Live')),
                      ButtonSegment(value: 'official', label: Text('Oficial')),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (value) => setState(() => _mode = value.first),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DayIndexItem>>(
                future: widget.repository.getDays(
                  citySlug: widget.config.citySlug,
                  year: widget.config.editionYear,
                  mode: _mode,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final days = snapshot.data ?? const <DayIndexItem>[];
                  if (days.isEmpty) {
                    return const Center(child: Text('Sin jornadas para este modo.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final startsAt = day.startsAt == null
                          ? 'Sin hora'
                          : DateFormat('EEEE d, HH:mm').format(day.startsAt!);

                      return Card(
                        child: ListTile(
                          title: Text(day.name),
                          subtitle: Text(startsAt),
                          trailing: Chip(label: Text('${day.processionEventsCount}')),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DayDetailPage(
                                  daySlug: day.slug,
                                  title: day.name,
                                  repository: widget.repository,
                                  config: widget.config,
                                  mode: _mode,
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
                    itemCount: days.length,
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
