class AppConfig {
  const AppConfig({
    required this.baseUrl,
    required this.citySlug,
    required this.editionYear,
    required this.mode,
    required this.simulatedNowFromEnv,
    required this.planningShareBaseUrl,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
  });

  final String baseUrl;
  final String citySlug;
  final int editionYear;
  final String mode;
  final DateTime? simulatedNowFromEnv;
  final String planningShareBaseUrl;
  final String androidStoreUrl;
  final String iosStoreUrl;

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
    const rawSimulatedNow = String.fromEnvironment(
      'SIMULATED_NOW',
      defaultValue: '',
    );
    const rawPlanningShareBaseUrl = String.fromEnvironment(
      'PLANNING_SHARE_BASE_URL',
      defaultValue: 'https://larevira.app/planning/share',
    );
    const rawAndroidStoreUrl = String.fromEnvironment(
      'ANDROID_STORE_URL',
      defaultValue:
          'https://play.google.com/store/apps/details?id=com.larevira.larevira_app_flutter',
    );
    const rawIosStoreUrl = String.fromEnvironment(
      'IOS_STORE_URL',
      defaultValue: 'https://apps.apple.com/app/id0000000000',
    );

    return AppConfig(
      baseUrl: rawBaseUrl,
      citySlug: rawCitySlug,
      editionYear: int.tryParse(rawEditionYear) ?? 2026,
      mode: _validModes.contains(rawMode) ? rawMode : 'all',
      simulatedNowFromEnv: rawSimulatedNow.isEmpty
          ? null
          : DateTime.tryParse(rawSimulatedNow),
      planningShareBaseUrl: rawPlanningShareBaseUrl,
      androidStoreUrl: rawAndroidStoreUrl,
      iosStoreUrl: rawIosStoreUrl,
    );
  }
}
