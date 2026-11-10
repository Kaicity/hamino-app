/// Giao diện dịch vụ hiển thị thông báo chạy nền (Ongoing Timer Notification)
abstract class INotificationService {
  Future<void> initialize();
  Future<void> showWorkoutNotification({
    required String title,
    required String body,
    bool isOngoing = true,
  });
  Future<void> cancelWorkoutNotification();
}

