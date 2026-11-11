import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'audio_service_interface.dart';

/// Dịch vụ quản lý và phát hiệu ứng âm thanh SFX độ trễ thấp (< 50ms)
class AudioSfxService implements IAudioService {
  static const String beepShortAsset = 'audio/beep_short.wav';
  static const String beepHighAsset = 'audio/beep_high.wav';
  static const String whistleStartAsset = 'audio/whistle_start.wav';
  static const String restChimeAsset = 'audio/rest_chime.wav';
  static const String victoryFanfareAsset = 'audio/victory_fanfare.wav';

  final AudioPlayer _beepShortPlayer;
  final AudioPlayer _beepHighPlayer;
  final AudioPlayer _whistlePlayer;
  final AudioPlayer _restPlayer;
  final AudioPlayer _fanfarePlayer;

  bool _isInitialized = false;
  bool isSoundEnabled = true;

  AudioSfxService({
    AudioPlayer? beepShortPlayer,
    AudioPlayer? beepHighPlayer,
    AudioPlayer? whistlePlayer,
    AudioPlayer? restPlayer,
    AudioPlayer? fanfarePlayer,
  })  : _beepShortPlayer = beepShortPlayer ?? AudioPlayer(),
        _beepHighPlayer = beepHighPlayer ?? AudioPlayer(),
        _whistlePlayer = whistlePlayer ?? AudioPlayer(),
        _restPlayer = restPlayer ?? AudioPlayer(),
        _fanfarePlayer = fanfarePlayer ?? AudioPlayer();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Cấu hình chế độ lowLatency cho các âm đếm giây và còi để phát tức thì (< 50ms)
      await _beepShortPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _beepHighPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _whistlePlayer.setPlayerMode(PlayerMode.lowLatency);
      await _restPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _fanfarePlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // Pre-cache và preload Source vào bộ nhớ RAM
      await _beepShortPlayer.setSource(AssetSource(beepShortAsset));
      await _beepHighPlayer.setSource(AssetSource(beepHighAsset));
      await _whistlePlayer.setSource(AssetSource(whistleStartAsset));
      await _restPlayer.setSource(AssetSource(restChimeAsset));
      await _fanfarePlayer.setSource(AssetSource(victoryFanfareAsset));

      _isInitialized = true;
      debugPrint('[AudioSfxService] SFX assets preloaded successfully.');
    } catch (e) {
      debugPrint('[AudioSfxService] Error during SFX initialization: $e');
      // Không crash app nếu môi trường không hỗ trợ native audio player
      _isInitialized = true;
    }
  }

  Future<void> _playSound(AudioPlayer player, String assetPath) async {
    if (!isSoundEnabled) return;
    try {
      if (!_isInitialized) {
        await initialize();
      }
      await player.stop();
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[AudioSfxService] Error playing $assetPath: $e');
    }
  }

  @override
  Future<void> playBeepShort() async {
    await _playSound(_beepShortPlayer, beepShortAsset);
  }

  @override
  Future<void> playBeepHigh() async {
    await _playSound(_beepHighPlayer, beepHighAsset);
  }

  @override
  Future<void> playWhistleStart() async {
    await _playSound(_whistlePlayer, whistleStartAsset);
  }

  @override
  Future<void> playBellWork() async {
    // Whistle start là âm còi báo vào hiệp tập
    await playWhistleStart();
  }

  @override
  Future<void> playChimeRest() async {
    await _playSound(_restPlayer, restChimeAsset);
  }

  @override
  Future<void> playVictoryFanfare() async {
    await _playSound(_fanfarePlayer, victoryFanfareAsset);
  }

  @override
  Future<void> stop() async {
    try {
      await Future.wait([
        _beepShortPlayer.stop(),
        _beepHighPlayer.stop(),
        _whistlePlayer.stop(),
        _restPlayer.stop(),
        _fanfarePlayer.stop(),
      ]);
    } catch (e) {
      debugPrint('[AudioSfxService] Error stopping audio: $e');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await Future.wait([
        _beepShortPlayer.dispose(),
        _beepHighPlayer.dispose(),
        _whistlePlayer.dispose(),
        _restPlayer.dispose(),
        _fanfarePlayer.dispose(),
      ]);
    } catch (e) {
      debugPrint('[AudioSfxService] Error disposing audio players: $e');
    }
  }
}

