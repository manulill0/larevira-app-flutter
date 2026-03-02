class SyncStatus {
  const SyncStatus({required this.version, required this.lastModifiedAt});

  final String version;
  final DateTime? lastModifiedAt;

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      version: (json['version'] ?? '') as String,
      lastModifiedAt: DateTime.tryParse(
        (json['last_modified_at'] ?? '') as String,
      ),
    );
  }
}
