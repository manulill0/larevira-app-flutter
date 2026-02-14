class BrotherhoodDetail {
  const BrotherhoodDetail({
    required this.name,
    required this.fullName,
    required this.history,
    required this.foundationYear,
    required this.colorHex,
    required this.headquartersName,
    required this.headquartersAddress,
    required this.figuresCount,
    required this.pasosCount,
    required this.bandsCount,
    required this.debutsCount,
    required this.newsTitles,
  });

  final String name;
  final String fullName;
  final String history;
  final int? foundationYear;
  final String colorHex;
  final String headquartersName;
  final String headquartersAddress;
  final int figuresCount;
  final int pasosCount;
  final int bandsCount;
  final int debutsCount;
  final List<String> newsTitles;

  factory BrotherhoodDetail.fromJson(Map<String, dynamic> json) {
    final headquarters = (json['headquarters'] as Map<String, dynamic>? ?? const {});
    final news = (json['news'] as List<dynamic>? ?? const []);

    return BrotherhoodDetail(
      name: (json['name'] ?? 'Hermandad') as String,
      fullName: (json['full_name'] ?? '') as String,
      history: (json['history'] ?? '') as String,
      foundationYear: (json['foundation_year'] as num?)?.toInt(),
      colorHex: (json['color_hex'] ?? '#8B1E3F') as String,
      headquartersName: (headquarters['name'] ?? '') as String,
      headquartersAddress: (headquarters['address'] ?? '') as String,
      figuresCount: (json['figures'] as List<dynamic>? ?? const []).length,
      pasosCount: (json['pasos'] as List<dynamic>? ?? const []).length,
      bandsCount: (json['bands'] as List<dynamic>? ?? const []).length,
      debutsCount: (json['debuts'] as List<dynamic>? ?? const []).length,
      newsTitles: news
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['title'] ?? '') as String)
          .where((title) => title.isNotEmpty)
          .toList(growable: false),
    );
  }
}
