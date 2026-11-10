/// Tiện ích chuyển đổi và định dạng thời gian cho các bài tập
class TimeFormatter {
  TimeFormatter._();

  /// Chuyển đổi số giây thành chuỗi định dạng mm:ss (hoặc hh:mm:ss nếu >= 1 giờ)
  /// Ví dụ: 65 -> "01:05", 3665 -> "01:01:05"
  static String formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutesStr:$secondsStr';
    }

    return '$minutesStr:$secondsStr';
  }

  /// Định dạng Duration thành mm:ss
  static String formatDuration(Duration duration) {
    return formatSeconds(duration.inSeconds);
  }

  /// Chuyển đổi số giây thành chuỗi hiển thị ngắn gọn tiếng Việt
  /// Ví dụ: 90 -> "1m 30s", 60 -> "1m", 45 -> "45s"
  static String formatSecondsToReadable(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }
    final minutes = totalSeconds ~/ 60;
    final remainingSeconds = totalSeconds % 60;

    if (remainingSeconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remainingSeconds}s';
  }
}

