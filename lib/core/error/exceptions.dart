/// Ngoại lệ ném ra khi thao tác với cơ sở dữ liệu gặp lỗi
class DatabaseException implements Exception {
  final String message;
  final dynamic cause;

  const DatabaseException(this.message, [this.cause]);

  @override
  String toString() => 'DatabaseException: $message ${cause != null ? '($cause)' : ''}';
}

/// Ngoại lệ ném ra khi phát âm thanh hoặc khởi tạo Audio Session thất bại
class AudioException implements Exception {
  final String message;
  final dynamic cause;

  const AudioException(this.message, [this.cause]);

  @override
  String toString() => 'AudioException: $message ${cause != null ? '($cause)' : ''}';
}

/// Ngoại lệ liên quan đến thiết bị phần cứng (Wakelock, Notifications)
class DeviceHardwareException implements Exception {
  final String message;
  final dynamic cause;

  const DeviceHardwareException(this.message, [this.cause]);

  @override
  String toString() => 'DeviceHardwareException: $message ${cause != null ? '($cause)' : ''}';
}

