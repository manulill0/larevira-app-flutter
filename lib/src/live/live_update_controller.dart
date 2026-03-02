import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../config/app_config.dart';
import '../data/repositories/larevira_repository.dart';

const _pendingProcessionStatusUpdateKey = 'pending_procession_status_update_v1';

class ProcessionStatusUpdate {
  const ProcessionStatusUpdate({
    required this.citySlug,
    required this.year,
    required this.daySlug,
    required this.dayName,
    required this.status,
    required this.brotherhoodSlug,
    required this.brotherhoodName,
    required this.title,
    required this.body,
  });

  final String citySlug;
  final int year;
  final String daySlug;
  final String dayName;
  final String status;
  final String brotherhoodSlug;
  final String brotherhoodName;
  final String title;
  final String body;

  Map<String, dynamic> toJson() {
    return {
      'city_slug': citySlug,
      'year': year,
      'day_slug': daySlug,
      'day_name': dayName,
      'status': status,
      'brotherhood_slug': brotherhoodSlug,
      'brotherhood_name': brotherhoodName,
      'title': title,
      'body': body,
    };
  }

  bool matchesDay({
    required String citySlug,
    required int year,
    required String daySlug,
  }) {
    return this.citySlug == citySlug &&
        this.year == year &&
        this.daySlug == daySlug;
  }

  static ProcessionStatusUpdate? fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] != 'procession_status_changed') {
      return null;
    }

    final citySlug = (data['city_slug'] ?? '').trim();
    final daySlug = (data['day_slug'] ?? '').trim();
    final year = int.tryParse((data['year'] ?? '').toString());

    if (citySlug.isEmpty || daySlug.isEmpty || year == null) {
      return null;
    }

    return ProcessionStatusUpdate(
      citySlug: citySlug,
      year: year,
      daySlug: daySlug,
      dayName: (data['day_name'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      brotherhoodSlug: (data['brotherhood_slug'] ?? '').toString(),
      brotherhoodName: (data['brotherhood_name'] ?? '').toString(),
      title: (data['title'] ?? message.notification?.title ?? 'Actualizacion')
          .toString(),
      body:
          (data['body'] ??
                  message.notification?.body ??
                  'Hay cambios en una jornada.')
              .toString(),
    );
  }

  static ProcessionStatusUpdate? fromJson(Map<String, dynamic> json) {
    final citySlug = (json['city_slug'] ?? '').toString().trim();
    final daySlug = (json['day_slug'] ?? '').toString().trim();
    final year = switch (json['year']) {
      final int value => value,
      final num value => value.toInt(),
      _ => int.tryParse((json['year'] ?? '').toString()),
    };

    if (citySlug.isEmpty || daySlug.isEmpty || year == null) {
      return null;
    }

    return ProcessionStatusUpdate(
      citySlug: citySlug,
      year: year,
      daySlug: daySlug,
      dayName: (json['day_name'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      brotherhoodSlug: (json['brotherhood_slug'] ?? '').toString(),
      brotherhoodName: (json['brotherhood_name'] ?? '').toString(),
      title: (json['title'] ?? 'Actualizacion').toString(),
      body: (json['body'] ?? 'Hay cambios en una jornada.').toString(),
    );
  }
}

Future<void> persistPendingProcessionStatusUpdate(RemoteMessage message) async {
  final update = ProcessionStatusUpdate.fromRemoteMessage(message);
  if (update == null) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _pendingProcessionStatusUpdateKey,
    jsonEncode(update.toJson()),
  );
}

Future<ProcessionStatusUpdate?> takePendingProcessionStatusUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_pendingProcessionStatusUpdateKey);
  if (raw == null || raw.isEmpty) {
    return null;
  }

  await prefs.remove(_pendingProcessionStatusUpdateKey);

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return ProcessionStatusUpdate.fromJson(decoded);
    }
    if (decoded is Map) {
      return ProcessionStatusUpdate.fromJson(
        decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }
  } catch (error, stackTrace) {
    developer.log(
      'Failed to decode pending background update.',
      name: 'LiveUpdateController',
      error: error,
      stackTrace: stackTrace,
    );
  }
  return null;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    // If Firebase was already initialized or initialization is unavailable in
    // the background isolate, we still try to persist the payload.
  }

  await persistPendingProcessionStatusUpdate(message);
}

class LiveUpdateController extends ChangeNotifier {
  LiveUpdateController._({
    required LareviraRepository repository,
    required AppConfig config,
  }) : _repository = repository,
       _config = config;

  static const _installationIdKey = 'push_installation_id_v1';
  static const _channelId = 'procession_updates';
  static const _channelName = 'Actualizaciones de procesiones';

  final LareviraRepository _repository;
  final AppConfig _config;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<ProcessionStatusUpdate> _updatesController =
      StreamController<ProcessionStatusUpdate>.broadcast();

  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _ready = false;

  Stream<ProcessionStatusUpdate> get updates => _updatesController.stream;

  static Future<LiveUpdateController> create({
    required LareviraRepository repository,
    required AppConfig config,
  }) async {
    final controller = LiveUpdateController._(
      repository: repository,
      config: config,
    );
    await controller._initialize();
    return controller;
  }

  Future<void> _initialize() async {
    if (_ready) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (_) {
      developer.log(
        'Firebase initialization failed for push notifications.',
        name: 'LiveUpdateController',
      );
      return;
    }

    await _initializeLocalNotifications();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    developer.log(
      'Notification permission status: ${settings.authorizationStatus.name}',
      name: 'LiveUpdateController',
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _ready = true;
      developer.log(
        'Push registration skipped because notifications are denied.',
        name: 'LiveUpdateController',
      );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      developer.log(
        'Enabled iOS foreground notification presentation.',
        name: 'LiveUpdateController',
      );
    }

    unawaited(_registerCurrentToken());

    _messageSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleUpdateEventOnly);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleUpdateEventOnly(initialMessage);
    }

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
      developer.log(
        'FCM token refreshed: $token',
        name: 'LiveUpdateController',
      );
      _registerToken(token);
    });

    _ready = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Avisos de cambios importantes en las procesiones.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _registerCurrentToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = await _waitForApnsToken();
      if (apnsToken == null || apnsToken.isEmpty) {
        developer.log(
          'APNs token not available after waiting; skipping FCM token registration.',
          name: 'LiveUpdateController',
        );
        return;
      }

      developer.log(
        'APNs token received: $apnsToken',
        name: 'LiveUpdateController',
      );
    }

    try {
      final token = await _messaging.getToken();
      developer.log(
        'FCM token received: ${token ?? '(null)'}',
        name: 'LiveUpdateController',
      );
      await _registerToken(token);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to obtain FCM token.',
        name: 'LiveUpdateController',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String?> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        return apnsToken;
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    return null;
  }

  Future<void> _registerToken(String? token) async {
    final trimmed = token?.trim() ?? '';
    if (trimmed.isEmpty) {
      return;
    }

    final installationId = await _getOrCreateInstallationId();

    try {
      await _repository.registerPushToken(
        installationId: installationId,
        token: trimmed,
        platform: _platformName,
        citySlug: _config.citySlug,
        year: _config.editionYear,
      );
      developer.log(
        'Push token registered in backend for installation $installationId.',
        name: 'LiveUpdateController',
      );
    } catch (_) {
      developer.log(
        'Failed to register push token in backend.',
        name: 'LiveUpdateController',
      );
    }
  }

  Future<String> _getOrCreateInstallationId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_installationIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure();
    final created =
        '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
        '-${random.nextInt(1 << 32).toRadixString(36)}';
    await prefs.setString(_installationIdKey, created);
    return created;
  }

  String get _platformName {
    if (kIsWeb) {
      return 'web';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    }
    return 'unknown';
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final update = ProcessionStatusUpdate.fromRemoteMessage(message);

    if (update != null) {
      await _syncCachesFor(update);
      developer.log(
        'Foreground push received for ${update.daySlug} (${update.status}).',
        name: 'LiveUpdateController',
      );
      _updatesController.add(update);
    }

    // On iOS, foreground presentation is already handled by FCM itself via
    // setForegroundNotificationPresentationOptions, so showing a local
    // notification here would duplicate the alert.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return;
    }

    final title = update?.title ?? message.notification?.title;
    final body = update?.body ?? message.notification?.body;
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await _localNotifications.show(
      _notificationIdFor(message),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'Avisos de cambios importantes en las procesiones.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  int _notificationIdFor(RemoteMessage message) {
    const maxSigned32BitInt = 0x7fffffff;
    final rawId =
        (message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}')
            .hashCode;
    return rawId & maxSigned32BitInt;
  }

  Future<void> _handleUpdateEventOnly(RemoteMessage message) async {
    final update = ProcessionStatusUpdate.fromRemoteMessage(message);
    if (update != null) {
      await _syncCachesFor(update);
      developer.log(
        'Push tap/background delivery for ${update.daySlug} (${update.status}).',
        name: 'LiveUpdateController',
      );
      _updatesController.add(update);
    }
  }

  Future<void> syncPendingUpdateIfAny() async {
    final pending = await takePendingProcessionStatusUpdate();
    if (pending == null) {
      return;
    }

    await _syncCachesFor(pending);
    _updatesController.add(pending);
  }

  Future<void> _syncCachesFor(ProcessionStatusUpdate update) async {
    const modes = <String>['all', 'live', 'official'];

    for (final mode in modes) {
      try {
        await _repository.syncDays(
          citySlug: update.citySlug,
          year: update.year,
          mode: mode,
        );
      } catch (_) {
        // Si falla una sincronización puntual, no bloqueamos el resto.
      }

      try {
        await _repository.syncDayDetail(
          citySlug: update.citySlug,
          year: update.year,
          daySlug: update.daySlug,
          mode: mode,
        );
      } catch (_) {
        // Algunas combinaciones de modo pueden no devolver datos; seguimos.
      }
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    _updatesController.close();
    super.dispose();
  }
}
