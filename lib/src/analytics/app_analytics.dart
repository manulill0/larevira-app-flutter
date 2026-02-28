import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../config/app_config.dart';

class AppAnalytics {
  AppAnalytics._({
    required FirebaseAnalytics analytics,
    required this.defaultParameters,
  }) : _analytics = analytics,
       observer = FirebaseAnalyticsObserver(analytics: analytics);

  final FirebaseAnalytics _analytics;
  final Map<String, Object> defaultParameters;
  final FirebaseAnalyticsObserver observer;

  static Future<AppAnalytics?> create(AppConfig config) async {
    if (!config.firebaseAnalyticsEnabled) {
      return null;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return AppAnalytics._(
        analytics: FirebaseAnalytics.instance,
        defaultParameters: <String, Object>{
          'app': 'larevira_app_flutter',
          'city_slug': config.citySlug,
          'edition_year': config.editionYear,
          'mode': config.mode,
        },
      );
    } catch (error, stackTrace) {
      developer.log(
        'Firebase Analytics unavailable. Run flutterfire configure to enable it.',
        name: 'AppAnalytics',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  void track(
    String event, {
    Map<String, Object> parameters = const <String, Object>{},
  }) {
    unawaited(
      _analytics.logEvent(
        name: event,
        parameters: <String, Object>{...defaultParameters, ...parameters},
      ),
    );
  }

  void trackScreen(String screenName) {
    unawaited(
      _analytics.logScreenView(screenName: screenName, screenClass: screenName),
    );
  }
}
