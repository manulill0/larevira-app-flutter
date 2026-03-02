import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../data/models/day_detail_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../live/status_style.dart';
import '../../live/live_update_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';
import 'procession_map_page.dart';

class DayDetailPage extends StatefulWidget {
  const DayDetailPage({
    super.key,
    required this.daySlug,
    required this.title,
    required this.repository,
    required this.config,
    required this.mode,
    required this.favoritesController,
    required this.liveUpdateController,
    this.embedded = false,
  });

  final String daySlug;
  final String title;
  final String mode;
  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final LiveUpdateController liveUpdateController;
  final bool embedded;

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  Future<DayDetail>? _future;
  StreamSubscription<ProcessionStatusUpdate>? _updateSubscription;
  bool _refreshInFlight = false;
  DateTime? _lastUpdatedAt;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _updateSubscription = widget.liveUpdateController.updates.listen((update) {
      if (!mounted) {
        return;
      }
      if (!update.matchesDay(
        citySlug: widget.config.citySlug,
        year: widget.config.editionYear,
        daySlug: widget.daySlug,
      )) {
        return;
      }
      _refreshNow();
    });
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

  Future<DayDetail> _load({bool preferRemote = false}) async {
    final detail = await widget.repository.getDayDetail(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
      daySlug: widget.daySlug,
      mode: widget.mode,
      preferRemote: preferRemote,
    );
    _lastUpdatedAt = DateTime.now();
    return detail;
  }

  Future<void> _manualRefresh() async {
    await _refreshNow();
  }

  Future<void> _refreshNow() async {
    if (_refreshInFlight) {
      return;
    }

    _refreshInFlight = true;

    try {
      final detail = await widget.repository.refreshDayDetail(
        citySlug: widget.config.citySlug,
        year: widget.config.editionYear,
        daySlug: widget.daySlug,
        mode: widget.mode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _future = Future<DayDetail>.value(detail);
        _lastUpdatedAt = DateTime.now();
      });
    } catch (_) {
      // Conservamos los datos visibles si no hay red.
    } finally {
      _refreshInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = AppScaffoldBackground(
      child: RefreshIndicator(
        onRefresh: _manualRefresh,
        child: FutureBuilder<DayDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return ListView(
                children: const [
                  SizedBox(height: 240),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            final detail = snapshot.data;
            if (detail == null) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Sin datos de jornada.')),
                ],
              );
            }

            return ListenableBuilder(
              listenable: widget.favoritesController,
              builder: (context, child) {
                final favoriteSlugs = widget.favoritesController.all;
                final orderedEvents = [...detail.processionEvents]
                  ..sort((a, b) {
                    final af = favoriteSlugs.contains(a.brotherhoodSlug);
                    final bf = favoriteSlugs.contains(b.brotherhoodSlug);
                    if (af == bf) {
                      return a.brotherhoodName.compareTo(b.brotherhoodName);
                    }
                    return af ? -1 : 1;
                  });

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Text(
                      '${detail.name} · ${detail.processionEvents.length} cofradías',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lastUpdatedAt == null
                          ? 'Sin actualizar'
                          : 'Última actualización ${DateFormat('HH:mm:ss').format(_lastUpdatedAt!)}',
                    ),
                    const SizedBox(height: 12),
                    for (final event in orderedEvents) ...[
                      _ProcessionCard(
                        event: event,
                        isFavorite: widget.favoritesController.isFavorite(
                          event.brotherhoodSlug,
                        ),
                        onToggleFavorite: () => widget.favoritesController
                            .toggle(event.brotherhoodSlug),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Actualizar ahora',
            onPressed: () {
              _refreshNow();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content,
    );
  }
}

class _ProcessionCard extends StatelessWidget {
  const _ProcessionCard({
    required this.event,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final DayProcessionEvent event;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final style = statusStyleFor(event.status);

    return Card(
      color: isFavorite ? const Color(0xFFFFF4DB) : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: parseHexColor(event.brotherhoodColorHex),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.brotherhoodName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? const Color(0xFFC9983E) : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    style.label,
                    style: TextStyle(
                      color: style.foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (event.officialNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(event.officialNote),
            ],
            const SizedBox(height: 10),
            if (event.routePoints.isNotEmpty ||
                event.schedulePoints.any((point) => point.hasLocation))
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProcessionMapPage(
                          title: event.brotherhoodName,
                          colorHex: event.brotherhoodColorHex,
                          routePoints: event.routePoints,
                          routeSections: event.routeSections,
                          schedulePoints: event.schedulePoints,
                          status: event.status,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver itinerario en mapa'),
                ),
              ),
            if (event.routePoints.isNotEmpty ||
                event.schedulePoints.any((point) => point.hasLocation))
              const SizedBox(height: 10),
            if (event.schedulePoints.isEmpty)
              const Text('Sin puntos de paso cargados.')
            else
              ...event.schedulePoints.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(point.name)),
                      Text(
                        point.plannedAt == null
                            ? '--:--'
                            : DateFormat('HH:mm').format(point.plannedAt!),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
