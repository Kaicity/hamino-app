import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/services/audio_service_interface.dart';
import 'package:hamino_app/core/services/tts_service_interface.dart';
import 'package:hamino_app/features/settings/domain/entities/user_settings_entity.dart';
import 'package:hamino_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:hamino_app/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:hamino_app/features/settings/presentation/bloc/settings_state.dart';

class MockSettingsRepository implements SettingsRepository {
  UserSettingsEntity currentSettings = const UserSettingsEntity();

  @override
  Future<UserSettingsEntity> getSettings() async => currentSettings;

  @override
  Future<void> saveSettings(UserSettingsEntity settings) async {
    currentSettings = settings;
  }
}

class MockTtsService implements ITtsService {
  @override
  bool isTtsEnabled = true;

  bool get isSpeaking => false;
  String currentLanguage = 'vi-VN';
  double currentSpeechRate = 0.52;

  String? spokenText;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isLanguageAvailable(String languageCode) async => true;

  @override
  Future<void> setLanguage(String languageCode) async {
    currentLanguage = languageCode;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    currentSpeechRate = rate;
  }

  @override
  Future<void> setPitch(double pitch) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> speak(String text, {bool awaitCompletion = false}) async {
    spokenText = text;
  }

  @override
  Future<void> stop() async {}
}

class MockAudioService implements IAudioService {
  @override
  bool isSoundEnabled = true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> playBeepShort() async {}

  @override
  Future<void> playBeepHigh() async {}

  @override
  Future<void> playWhistleStart() async {}

  @override
  Future<void> playBellWork() async {}

  @override
  Future<void> playChimeRest() async {}

  @override
  Future<void> playVictoryFanfare() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  late MockSettingsRepository repository;
  late MockTtsService ttsService;
  late MockAudioService audioService;
  late SettingsCubit cubit;

  setUp(() {
    repository = MockSettingsRepository();
    ttsService = MockTtsService();
    audioService = MockAudioService();
    cubit = SettingsCubit(
      repository: repository,
      ttsService: ttsService,
      audioService: audioService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('SettingsCubit Tests (TASK-6.1)', () {
    test('Initial state is SettingsInitial', () {
      expect(cubit.state, isA<SettingsInitial>());
    });

    test('loadSettings emits SettingsLoaded and syncs to services', () async {
      await cubit.loadSettings();

      expect(cubit.state, isA<SettingsLoaded>());
      final state = cubit.state as SettingsLoaded;
      expect(state.settings.isTtsEnabled, true);
      expect(ttsService.isTtsEnabled, true);
      expect(audioService.isSoundEnabled, true);
    });

    test('updateTtsEnabled toggles TTS and updates state and service', () async {
      await cubit.loadSettings();
      await cubit.updateTtsEnabled(false);

      final state = cubit.state as SettingsLoaded;
      expect(state.settings.isTtsEnabled, false);
      expect(ttsService.isTtsEnabled, false);
      expect(repository.currentSettings.isTtsEnabled, false);
    });

    test('updateLanguage updates language code and syncs with TTS', () async {
      await cubit.loadSettings();
      await cubit.updateLanguage('en-US');

      final state = cubit.state as SettingsLoaded;
      expect(state.settings.ttsLanguage, 'en-US');
      expect(ttsService.currentLanguage, 'en-US');
      expect(repository.currentSettings.ttsLanguage, 'en-US');
    });

    test('updateSpeechRate updates speech rate and syncs with TTS', () async {
      await cubit.loadSettings();
      await cubit.updateSpeechRate(0.75);

      final state = cubit.state as SettingsLoaded;
      expect(state.settings.speechRate, 0.75);
      expect(ttsService.currentSpeechRate, 0.75);
    });

    test('updateSfxEnabled toggles SFX and updates AudioService', () async {
      await cubit.loadSettings();
      await cubit.updateSfxEnabled(false);

      final state = cubit.state as SettingsLoaded;
      expect(state.settings.isSfxEnabled, false);
      expect(audioService.isSoundEnabled, false);
    });

    test('updateAudioDuckingEnabled updates ducking setting', () async {
      await cubit.loadSettings();
      await cubit.updateAudioDuckingEnabled(false);

      final state = cubit.state as SettingsLoaded;
      expect(state.settings.isAudioDuckingEnabled, false);
    });

    test('updateWakelockEnabled updates wakelock setting', () async {
      await cubit.loadSettings();
      await cubit.updateWakelockEnabled(false);

      final state = cubit.state as SettingsLoaded;
      expect(state.settings.isWakelockEnabled, false);
    });

    test('updateDefaultPrepareSeconds updates prepare time', () async {
      await cubit.loadSettings();
      await cubit.updateDefaultPrepareSeconds(15);

      final state = cubit.state as SettingsLoaded;
      expect(state.settings.defaultPrepareSeconds, 15);
    });

    test('testVoiceSample speaks sample text with current language', () async {
      await cubit.loadSettings();
      await cubit.testVoiceSample();

      expect(ttsService.spokenText, contains('Hamino Workout'));
    });
  });
}

