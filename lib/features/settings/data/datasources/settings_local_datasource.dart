import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_settings_entity.dart';

/// Interface data source lưu trữ cài đặt cục bộ
abstract class SettingsLocalDataSource {
  Future<UserSettingsEntity> getSettings();
  Future<void> saveSettings(UserSettingsEntity settings);
}

/// Triển khai thực tế với [SharedPreferences]
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String keyTtsEnabled = 'pref_tts_enabled';
  static const String keyTtsLanguage = 'pref_tts_language';
  static const String keySpeechRate = 'pref_speech_rate';
  static const String keySfxEnabled = 'pref_sfx_enabled';
  static const String keyAudioDucking = 'pref_audio_ducking_enabled';
  static const String keyKeepScreenAwake = 'pref_keep_screen_awake';
  static const String keyDefaultPrepareSeconds = 'pref_default_prepare_seconds';

  final SharedPreferences _prefs;

  SettingsLocalDataSourceImpl(this._prefs);

  @override
  Future<UserSettingsEntity> getSettings() async {
    return UserSettingsEntity(
      isTtsEnabled: _prefs.getBool(keyTtsEnabled) ?? true,
      ttsLanguage: _prefs.getString(keyTtsLanguage) ?? 'vi-VN',
      speechRate: _prefs.getDouble(keySpeechRate) ?? 0.52,
      isSfxEnabled: _prefs.getBool(keySfxEnabled) ?? true,
      isAudioDuckingEnabled: _prefs.getBool(keyAudioDucking) ?? true,
      isWakelockEnabled: _prefs.getBool(keyKeepScreenAwake) ?? true,
      defaultPrepareSeconds: _prefs.getInt(keyDefaultPrepareSeconds) ?? 10,
    );
  }

  @override
  Future<void> saveSettings(UserSettingsEntity settings) async {
    await _prefs.setBool(keyTtsEnabled, settings.isTtsEnabled);
    await _prefs.setString(keyTtsLanguage, settings.ttsLanguage);
    await _prefs.setDouble(keySpeechRate, settings.speechRate);
    await _prefs.setBool(keySfxEnabled, settings.isSfxEnabled);
    await _prefs.setBool(keyAudioDucking, settings.isAudioDuckingEnabled);
    await _prefs.setBool(keyKeepScreenAwake, settings.isWakelockEnabled);
    await _prefs.setInt(keyDefaultPrepareSeconds, settings.defaultPrepareSeconds);
  }
}

