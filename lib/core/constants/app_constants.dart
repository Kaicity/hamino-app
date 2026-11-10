/// Hằng số chung cho toàn bộ ứng dụng Hamino Workout
class AppConstants {
  AppConstants._();

  static const String appName = 'Hamino Workout';
  static const String appTagline = 'Calisthenics Precision Training';

  // Thời gian mặc định (giây)
  static const int defaultPrepareSeconds = 10;
  static const int defaultRestSeconds = 60;
  static const int defaultWorkSeconds = 45;
  static const int defaultRounds = 5;

  // Giới hạn thời gian (Time Cap mặc định: 20 phút = 1200 giây)
  static const int defaultTimeCapSeconds = 1200;

  // Tick interval cho Precision Timer (100ms)
  static const int timerTickIntervalMs = 100;
}

