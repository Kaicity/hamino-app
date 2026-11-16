import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/audio_service_interface.dart';
import '../../../../core/services/tts_service_interface.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;
  final ITtsService? ttsService;
  final IAudioService? audioService;

  SettingsCubit({
    required this.repository,
    this.ttsService,
    this.audioService,
  }) : super(const SettingsInitial());

  Future<void> loadSettings() async {
    final settings = await repository.getSettings();
    _syncServices(settings);
    emit(SettingsLoaded(settings: settings));
  }

  void _syncServices(UserSettingsEntity settings) {
    if (ttsService != null) {
      ttsService!.isTtsEnabled = settings.isTtsEnabled;
      ttsService!.setLanguage(settings.ttsLanguage);
      ttsService!.setSpeechRate(settings.speechRate);
    }
    if (audioService != null) {
      audioService!.isSoundEnabled = settings.isSfxEnabled;
    }
  }

  Future<void> updateTtsEnabled(bool enabled) async {
    if (state is! SettingsLoaded) return;
    final current = (state as SettingsLoaded).settings;
    final updated = current.copyWith(isTtsEnabled: enabled);
    ttsService?.isTtsEnabled = enabled;
    await repository.saveSettings(updated);
    emit((state as SettingsLoaded).copyWith(settings: updated));
  }

  Future<void> updateLanguage(String languageCode) async {
    if (state is! SettingsLoaded) return;
    final current = (state as SettingsLoaded).settings;
    final updated = current.copyWith(ttsLanguage: languageCode);
    ttsService?.setLanguage(languageCode);
    await repository.saveSettings(updated);
    emit((state as SettingsLoaded).copyWith(settings: updated));
  }

  Future<void> updateSpeechRate(double rate) async {
    if (state is! SettingsLoaded) return;
    final current = (state as SettingsLoaded).settings;
    final updated = current.copyWith(speechRate: rate);
    ttsService?.setSpeechRate(rate);
    await repository.saveSettings(updated);
    emit((state as SettingsLoaded).copyWith(settings: updated));
  }

  Future<void> updateSfxEnabled(bool enabled) async {
    if (state is! SettingsLoaded) return;
    final current = (state as SettingsLoaded).settings;
    final updated = current.copyWith(isSfxEnabled: enabled);
    audioService?.isSoundEnabled = enabled;
    await repository.saveSettings(updated);
    emit((state as SettingsLoaded).copyWith(settings: updated));
  }

  Future<void> updateAudioDuckingEnabled(bool enabled) async {
    if (state is! SettingsLoaded) return;
    final current = (state as SettingsLoaded).settings;
    final updated = current.copyWith(isAudioDuckingEnabled: enabled);
    await repository.saveSettings(updated);
    emit((state as SettingsLoaded).copyWith(settings: updated));
  }

  Future<void> updateWakelockEnabled(bool enabled) async {
    if (state is! SettingsLoaded) return;
    final current = (state as SettingsLoaded).settings;
    final updated = current.copyWith(isWakelockEnabled: enabled);
    await repository.saveSettings(updated);
    emit((state as SettingsLoaded).copyWith(settings: updated));
  }

  Future<void> updateDefaultPrepareSeconds(int seconds) async {
    if (state is! SettingsLoaded) return;
    final current = (state as SettingsLoaded).settings;
    final updated = current.copyWith(defaultPrepareSeconds: seconds);
    await repository.saveSettings(updated);
    emit((state as SettingsLoaded).copyWith(settings: updated));
  }

  Future<void> testVoiceSample() async {
    if (state is! SettingsLoaded || ttsService == null) return;
    final settings = (state as SettingsLoaded).settings;

    emit((state as SettingsLoaded).copyWith(isTestingVoice: true));

    try {
      ttsService!.isTtsEnabled = true;
      await ttsService!.setLanguage(settings.ttsLanguage);
      await ttsService!.setSpeechRate(settings.speechRate);

      final sampleText = settings.ttsLanguage.startsWith('en')
          ? 'Hello! This is Hamino Workout coach. Get ready to push your limits!'
          : 'Xin chào! Tôi là trợ lý ảo Hamino Workout. Chuẩn bị tập luyện hết mình nào!';

      await ttsService!.speak(sampleText, awaitCompletion: true);
    } finally {
      ttsService!.isTtsEnabled = settings.isTtsEnabled;
      if (!isClosed && state is SettingsLoaded) {
        emit((state as SettingsLoaded).copyWith(isTestingVoice: false));
      }
    }
  }
}

