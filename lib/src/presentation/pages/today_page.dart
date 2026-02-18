import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../data/models/brotherhood_model.dart';
import '../../data/models/day_models.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../mode/mode_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';
import '../widgets/card_list_tile.dart';
import 'day_detail_page.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.simulatedClockController,
    required this.modeController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final SimulatedClockController simulatedClockController;
  final ModeController modeController;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late Future<List<DayIndexItem>> _daysFuture;
  late Future<List<BrotherhoodItem>> _brotherhoodsFuture;
  late String _mode;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.modeController.mode;
    widget.modeController.addListener(_onModeChanged);
    _daysFuture = _loadDays();
    _brotherhoodsFuture = _loadBrotherhoods();
  }

  @override
  void dispose() {
    widget.modeController.removeListener(_onModeChanged);
    super.dispose();
  }

  void _onModeChanged() {
    final nextMode = widget.modeController.mode;
    if (nextMode == _mode) {
      return;
    }
    setState(() {
      _mode = nextMode;
      _daysFuture = _loadDays();
      _brotherhoodsFuture = _loadBrotherhoods();
    });
  }

  Future<List<DayIndexItem>> _loadDays() {
    return widget.repository.getDays(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
      mode: _mode,
    );
  }

  Future<List<BrotherhoodItem>> _loadBrotherhoods() {
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
      await Future.wait<void>([
        widget.repository.syncDays(
          citySlug: widget.config.citySlug,
          year: widget.config.editionYear,
          mode: _mode,
        ),
        widget.repository.syncBrotherhoods(
          citySlug: widget.config.citySlug,
          year: widget.config.editionYear,
        ),
      ]);

      setState(() {
        _daysFuture = _loadDays();
        _brotherhoodsFuture = _loadBrotherhoods();
      });

      await Future.wait<dynamic>([_daysFuture, _brotherhoodsFuture]);
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.simulatedClockController,
      builder: (context, child) {
        return AppScaffoldBackground(
          child: SafeArea(
            child: FutureBuilder<List<DayIndexItem>>(
              future: _daysFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _ErrorState(
                    message: snapshot.error.toString(),
                    baseUrl: widget.config.baseUrl,
                  );
                }

                final days = snapshot.data ?? const <DayIndexItem>[];
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Text(
                                'La Revira',
                                style: Theme.of(
                                  context,
                                ).appBarTheme.titleTextStyle,
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Actualizar',
                                onPressed: _syncing ? null : () => _refresh(),
                                icon: _syncing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.config.citySlug.toUpperCase()} ${widget.config.editionYear} · Modo $_mode',
                              ),
                              if (widget
                                  .simulatedClockController
                                  .isSimulating) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Fecha simulada: ${DateFormat('EEE dd/MM/yyyy HH:mm', 'es_ES').format(widget.simulatedClockController.now)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFA02943),
                                  ),
                                ),
                              ],
                            ],
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
                            listenable: widget.favoritesController,
                            builder: (context, child) {
                              return FutureBuilder<List<BrotherhoodItem>>(
                                future: _brotherhoodsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                          ConnectionState.done ||
                                      !snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }

                                  final favoriteSlugs =
                                      widget.favoritesController.all;
                                  if (favoriteSlugs.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  final favorites = snapshot.data!
                                      .where(
                                        (item) =>
                                            favoriteSlugs.contains(item.slug),
                                      )
                                      .toList(growable: false);
                                  if (favorites.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tus favoritas',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (final item in favorites)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: parseHexColor(
                                                  item.colorHex,
                                                ).withValues(alpha: 0.14),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 15,
                                                    color: parseHexColor(
                                                      item.colorHex,
                                                    ),
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
                                : DateFormat(
                                    'EEE d MMM, HH:mm',
                                    'es_ES',
                                  ).format(day.startsAt!);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CardListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF8B1E3F),
                                  child: Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(day.name),
                                subtitle: Text(
                                  '$formatted · ${day.processionEventsCount} cofradías',
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => DayDetailPage(
                                        daySlug: day.slug,
                                        title: day.name,
                                        repository: widget.repository,
                                        config: widget.config,
                                        mode: _mode,
                                        favoritesController:
                                            widget.favoritesController,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
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
  const _ErrorState({required this.message, required this.baseUrl});

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
