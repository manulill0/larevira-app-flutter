class BrotherhoodItem {
  const BrotherhoodItem({
    required this.name,
    required this.slug,
    required this.fullName,
    required this.colorHex,
  });

  final String name;
  final String slug;
  final String fullName;
  final String colorHex;

  factory BrotherhoodItem.fromJson(Map<String, dynamic> json) {
    return BrotherhoodItem(
      name: (json['name'] ?? 'Hermandad') as String,
      slug: (json['slug'] ?? '') as String,
      fullName: (json['full_name'] ?? '') as String,
      colorHex: (json['color_hex'] ?? '#8B1E3F') as String,
    );
  }
}
