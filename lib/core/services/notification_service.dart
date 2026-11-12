import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service_interface.dart';

/// Dịch vụ hiển thị thông báo chạy nền (Ongoing Notification) cho đồng hồ đếm giờ Hamino
class NotificationService implements INotificationService {
  static const int workoutNotificationId = 8888;
  static const String channelId = 'hamino_workout_timer';
  static const String channelName = 'Hamino Workout Timer';
  static const String channelDescription =
      'Thông báo đếm giờ thời gian thực cho bài tập Hamino';

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? notificationsPlugin})
      : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint(
              '[NotificationService] Notification tapped: ${response.payload}');
        },
      );

      // Cấu hình channel cụ thể cho Android với mức độ ưu tiên cao
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
            playSound: false,
            enableVibration: false,
          ),
        );
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Khởi tạo notification thành công');
    } catch (e) {
      debugPrint('[NotificationService] Khởi tạo thất bại hoặc môi trường test: $e');
    }
  }

  @override
  Future<void> showWorkoutNotification({
    required String title,
    required String body,
    bool isOngoing = true,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        onlyAlertOnce: true,
        showWhen: false,
        playSound: false,
        enableVibration: false,
        category: AndroidNotificationCategory.workout,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.show(
        workoutNotificationId,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('[NotificationService] Không thể hiển thị notification: $e');
    }
  }

  @override
  Future<void> cancelWorkoutNotification() async {
    try {
      await _notificationsPlugin.cancel(workoutNotificationId);
      debugPrint('[NotificationService] Đã hủy thông báo buổi tập');
    } catch (e) {
      debugPrint('[NotificationService] Lỗi khi hủy notification: $e');
    }
  }
}

