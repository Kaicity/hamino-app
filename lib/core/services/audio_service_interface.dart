/// Giao diện dịch vụ hiệu ứng âm thanh (SFX Beeps, Whistle, Chime)
abstract class IAudioService {
  Future<void> initialize();
  Future<void> playBeepShort();
  Future<void> playBeepHigh();
  Future<void> playWhistleStart();
  Future<void> playBellWork();
  Future<void> playChimeRest();
  Future<void> playVictoryFanfare();
  Future<void> stop();
  Future<void> dispose();
}

