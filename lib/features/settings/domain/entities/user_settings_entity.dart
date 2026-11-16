import 'package:equatable/equatable.dart';

/// Thực thể lưu trữ cấu hình cài đặt của người dùng
class UserSettingsEntity extends Equatable {
  /// Bật/tắt giọng đọc trợ lý ảo Text-To-Speech
  final bool isTtsEnabled;

  /// Ngôn ngữ giọng đọc ('vi-VN' hoặc 'en-US')
  final String ttsLanguage;

  /// Tốc độ giọng đọc (0.3x đến 1.0x, mặc định 0.52)
  final double speechRate;

  /// Bật/tắt hiệu ứng âm thanh SFX (còi, tiếng bíp)
  final bool isSfxEnabled;

  /// Tự động giảm âm lượng nhạc ngoài (Audio Ducking) khi đọc khẩu lệnh
  final bool isAudioDuckingEnabled;

  /// Luôn sáng màn hình trong lúc tập (Wakelock)
  final bool isWakelockEnabled;

  /// Thời gian đếm chuẩn bị mặc định (5, 10, hoặc 15 giây)
  final int defaultPrepareSeconds;

  const UserSettingsEntity({
    this.isTtsEnabled = true,
    this.ttsLanguage = 'vi-VN',
    this.speechRate = 0.52,
    this.isSfxEnabled = true,
    this.isAudioDuckingEnabled = true,
    this.isWakelockEnabled = true,
    this.defaultPrepareSeconds = 10,
  });

  UserSettingsEntity copyWith({
    bool? isTtsEnabled,
    String? ttsLanguage,
    double? speechRate,
    bool? isSfxEnabled,
    bool? isAudioDuckingEnabled,
    bool? isWakelockEnabled,
    int? defaultPrepareSeconds,
  }) {
    return UserSettingsEntity(
      isTtsEnabled: isTtsEnabled ?? this.isTtsEnabled,
      ttsLanguage: ttsLanguage ?? this.ttsLanguage,
      speechRate: speechRate ?? this.speechRate,
      isSfxEnabled: isSfxEnabled ?? this.isSfxEnabled,
      isAudioDuckingEnabled:
          isAudioDuckingEnabled ?? this.isAudioDuckingEnabled,
      isWakelockEnabled: isWakelockEnabled ?? this.isWakelockEnabled,
      defaultPrepareSeconds:
          defaultPrepareSeconds ?? this.defaultPrepareSeconds,
    );
  }

  @override
  List<Object?> get props => [
        isTtsEnabled,
        ttsLanguage,
        speechRate,
        isSfxEnabled,
        isAudioDuckingEnabled,
        isWakelockEnabled,
        defaultPrepareSeconds,
      ];
}

