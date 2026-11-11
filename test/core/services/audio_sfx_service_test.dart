import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/services/audio_sfx_service.dart';

class MockAudioPlayer extends Fake implements AudioPlayer {
  PlayerMode _mode = PlayerMode.mediaPlayer;
  @override
  Source? source;
  int playCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  PlayerMode get mode => _mode;

  @override
  Future<void> setPlayerMode(PlayerMode mode) async {
    _mode = mode;
  }

  @override
  Future<void> setSource(Source source) async {
    this.source = source;
  }

  @override
  Future<void> play(
    Source source, {
    double? volume,
    Duration? position,
    PlayerMode? mode,
    double? balance,
    AudioContext? ctx,
  }) async {
    playCalls++;
    this.source = source;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioPlayer beepShortPlayer;
  late MockAudioPlayer beepHighPlayer;
  late MockAudioPlayer whistlePlayer;
  late MockAudioPlayer restPlayer;
  late MockAudioPlayer fanfarePlayer;
  late AudioSfxService service;

  setUp(() {
    beepShortPlayer = MockAudioPlayer();
    beepHighPlayer = MockAudioPlayer();
    whistlePlayer = MockAudioPlayer();
    restPlayer = MockAudioPlayer();
    fanfarePlayer = MockAudioPlayer();

    service = AudioSfxService(
      beepShortPlayer: beepShortPlayer,
      beepHighPlayer: beepHighPlayer,
      whistlePlayer: whistlePlayer,
      restPlayer: restPlayer,
      fanfarePlayer: fanfarePlayer,
    );
  });

  group('AudioSfxService (TASK-4.1)', () {
    test('initialize configures lowLatency and preloads asset sources', () async {
      await service.initialize();

      expect(beepShortPlayer.mode, PlayerMode.lowLatency);
      expect(beepHighPlayer.mode, PlayerMode.lowLatency);
      expect(whistlePlayer.mode, PlayerMode.lowLatency);
      expect(restPlayer.mode, PlayerMode.lowLatency);
      expect(fanfarePlayer.mode, PlayerMode.mediaPlayer);

      expect(beepShortPlayer.source, isA<AssetSource>());
      expect(whistlePlayer.source, isA<AssetSource>());
    });

    test('plays sounds through dedicated players', () async {
      await service.playBeepShort();
      expect(beepShortPlayer.playCalls, 1);

      await service.playBeepHigh();
      expect(beepHighPlayer.playCalls, 1);

      await service.playWhistleStart();
      expect(whistlePlayer.playCalls, 1);

      await service.playBellWork();
      expect(whistlePlayer.playCalls, 2);

      await service.playChimeRest();
      expect(restPlayer.playCalls, 1);

      await service.playVictoryFanfare();
      expect(fanfarePlayer.playCalls, 1);
    });

    test('does not play sound when isSoundEnabled is false', () async {
      service.isSoundEnabled = false;

      await service.playBeepShort();
      await service.playWhistleStart();

      expect(beepShortPlayer.playCalls, 0);
      expect(whistlePlayer.playCalls, 0);
    });

    test('stop calls stop on all players', () async {
      await service.stop();

      expect(beepShortPlayer.stopCalls, 1);
      expect(beepHighPlayer.stopCalls, 1);
      expect(whistlePlayer.stopCalls, 1);
      expect(restPlayer.stopCalls, 1);
      expect(fanfarePlayer.stopCalls, 1);
    });

    test('dispose calls dispose on all players', () async {
      await service.dispose();

      expect(beepShortPlayer.disposeCalls, 1);
      expect(beepHighPlayer.disposeCalls, 1);
      expect(whistlePlayer.disposeCalls, 1);
      expect(restPlayer.disposeCalls, 1);
      expect(fanfarePlayer.disposeCalls, 1);
    });
  });
}
