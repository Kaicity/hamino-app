import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Dịch vụ quản lý Audio Focus & Ducking
/// Tự động giảm âm lượng nhạc nền (Spotify, Apple Music, Zing MP3) khi Hamino Workout phát khẩu lệnh
class AudioFocusService {
  AudioSession? _session;
  bool _isConfigured = false;
  bool _isActive = false;

  bool get isActive => _isActive;

  /// Cấu hình Audio Focus với cơ chế ducking (giảm âm lượng các app khác)
  Future<void> initialize() async {
    if (_isConfigured) return;

    try {
      _session = await AudioSession.instance;

      await _session!.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.assistant,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: false,
      ));

      _isConfigured = true;
      debugPrint('[AudioFocusService] Audio focus configured with duckOthers successfully.');
    } catch (e) {
      debugPrint('[AudioFocusService] Error configuring audio session: $e');
      _isConfigured = true;
    }
  }

  /// Kích hoạt Audio Focus: nhạc nền tự động giảm âm lượng xuống ~25%
  Future<bool> activate() async {
    try {
      if (!_isConfigured || _session == null) {
        await initialize();
      }
      if (_session != null) {
        final success = await _session!.setActive(true);
        _isActive = success;
        return success;
      }
      return false;
    } catch (e) {
      debugPrint('[AudioFocusService] Error activating audio focus: $e');
      return false;
    }
  }

  /// Hủy kích hoạt Audio Focus: nhạc nền tự động khôi phục về 100%
  Future<void> deactivate() async {
    try {
      if (_session != null && _isActive) {
        await _session!.setActive(false);
        _isActive = false;
      }
    } catch (e) {
      debugPrint('[AudioFocusService] Error deactivating audio focus: $e');
    }
  }
}

