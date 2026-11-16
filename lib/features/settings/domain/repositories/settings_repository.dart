import '../entities/user_settings_entity.dart';

/// Interface cho repository quản lý cài đặt hệ thống
abstract class SettingsRepository {
  /// Lấy toàn bộ cài đặt hiện tại
  Future<UserSettingsEntity> getSettings();

  /// Lưu toàn bộ cài đặt mới
  Future<void> saveSettings(UserSettingsEntity settings);
}

