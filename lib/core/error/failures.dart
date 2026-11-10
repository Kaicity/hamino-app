import 'package:equatable/equatable.dart';

/// Lớp cơ sở đại diện cho các lỗi nghiệp vụ trong hệ thống
abstract class Failure extends Equatable {
  final String message;
  final dynamic error;

  const Failure(this.message, [this.error]);

  @override
  List<Object?> get props => [message, error];
}

/// Lỗi liên quan đến Database (SQLite)
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.error]);
}

/// Lỗi liên quan đến Âm thanh (Audio / TTS)
class AudioFailure extends Failure {
  const AudioFailure(super.message, [super.error]);
}

/// Lỗi liên quan đến dữ liệu không hợp lệ
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.error]);
}

/// Lỗi không tìm thấy tài nguyên
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.error]);
}

/// Lỗi chung / ngoại lệ chưa xác định
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.error]);
}

