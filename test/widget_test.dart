import 'package:flutter_test/flutter_test.dart';

import 'package:larevira_app_flutter/src/config/app_config.dart';

void main() {
  test('AppConfig has sane defaults', () {
    final config = AppConfig.fromEnvironment();

    expect(config.baseUrl, isNotEmpty);
    expect(config.citySlug, isNotEmpty);
    expect(config.editionYear, greaterThan(2020));
  });
}
