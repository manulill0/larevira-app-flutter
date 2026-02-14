class DayIndexItem {
  const DayIndexItem({
    required this.slug,
    required this.name,
    required this.startsAt,
    required this.processionEventsCount,
  });

  final String slug;
  final String name;
  final DateTime? startsAt;
  final int processionEventsCount;

  factory DayIndexItem.fromJson(Map<String, dynamic> json) {
    return DayIndexItem(
      slug: (json['slug'] ?? '') as String,
      name: (json['name'] ?? 'Jornada') as String,
      startsAt: DateTime.tryParse((json['starts_at'] ?? '') as String),
      processionEventsCount: (json['procession_events_count'] as num?)?.toInt() ?? 0,
    );
  }
}
