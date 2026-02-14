class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.citySlug,
    required this.editionYear,
    required this.mode,
  });

  final String baseUrl;
  final String citySlug;
  final int editionYear;
  final String mode;

  static const _validModes = {'all', 'live', 'official'};

  factory AppConfig.fromEnvironment() {
    const rawBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://192.168.1.89:8001/api/v1',
    );
    const rawCitySlug = String.fromEnvironment(
      'CITY_SLUG',
      defaultValue: 'sevilla',
    );
    const rawEditionYear = String.fromEnvironment(
      'EDITION_YEAR',
      defaultValue: '2026',
    );
    const rawMode = String.fromEnvironment('MODE', defaultValue: 'all');

    return AppConfig(
      baseUrl: rawBaseUrl,
      citySlug: rawCitySlug,
      editionYear: int.tryParse(rawEditionYear) ?? 2026,
      mode: _validModes.contains(rawMode) ? rawMode : 'all',
    );
  }
}
