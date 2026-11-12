import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests (TASK-5.4)', () {
    test('NotificationService constants and safe execution', () async {
      final service = NotificationService();

      expect(NotificationService.channelId, 'hamino_workout_timer');
      expect(NotificationService.workoutNotificationId, 8888);

      // Verify safe calls in headless test environment (no crashes)
      await service.initialize();
      await service.showWorkoutNotification(
        title: 'Hamino Routine • Pull-ups',
        body: '[ĐANG TẬP] Còn 30s',
      );
      await service.cancelWorkoutNotification();
    });
  });
}

