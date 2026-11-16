import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hamino_app/core/services/audio_service_interface.dart';
import 'package:hamino_app/core/services/tts_service_interface.dart';
import 'package:hamino_app/features/settings/domain/entities/user_settings_entity.dart';
import 'package:hamino_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:hamino_app/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:hamino_app/features/settings/presentation/pages/settings_page.dart';

class MockSettingsRepository implements SettingsRepository {
  UserSettingsEntity settings = const UserSettingsEntity();

  @override
  Future<UserSettingsEntity> getSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettingsEntity settings) async {
    this.settings = settings;
  }
}

class MockTtsService implements ITtsService {
  @override
  bool isTtsEnabled = true;

  bool get isSpeaking => false;
  String currentLanguage = 'vi-VN';
  double currentSpeechRate = 0.52;

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
  Future<void> speak(String text, {bool awaitCompletion = false}) async {}

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
  final sl = GetIt.instance;
  late MockSettingsRepository mockRepo;
  late MockTtsService mockTts;
  late MockAudioService mockAudio;

  setUp(() {
    sl.reset();
    mockRepo = MockSettingsRepository();
    mockTts = MockTtsService();
    mockAudio = MockAudioService();

    sl.registerFactory<SettingsCubit>(
      () => SettingsCubit(
        repository: mockRepo,
        ttsService: mockTts,
        audioService: mockAudio,
      ),
    );
  });

  tearDown(() {
    sl.reset();
  });

  testWidgets('SettingsPage renders all sections, switches and about info', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final cubit = SettingsCubit(
      repository: mockRepo,
      ttsService: mockTts,
      audioService: mockAudio,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(cubit: cubit),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Headers
    expect(find.text('CÀI ĐẶT HỆ THỐNG'), findsOneWidget);
    expect(find.text('ÂM THANH & HUẤN LUYỆN VIÊN (AUDIO & COACH)'), findsOneWidget);
    expect(find.text('MÀN HÌNH & PIN (DISPLAY & BATTERY)'), findsOneWidget);
    expect(find.text('GIỚI THIỆU (ABOUT HAMINO)'), findsOneWidget);

    // Verify Switch Tiles
    expect(find.text('Giọng đọc Trợ lý ảo (TTS)'), findsOneWidget);
    expect(find.text('Âm thanh còi & tiếng bíp (SFX)'), findsOneWidget);
    expect(find.text('Tự động giảm âm nhạc ngoài (Audio Ducking)'), findsOneWidget);
    expect(find.text('Luôn giữ sáng màn hình (Wakelock)'), findsOneWidget);

    // Verify Language selection & Prepare seconds
    expect(find.text('🇻🇳 Tiếng Việt'), findsOneWidget);
    expect(find.text('🇺🇸 English'), findsOneWidget);
    expect(find.text('10 giây (Chuẩn)'), findsOneWidget);

    // Verify About details
    expect(find.text('HAMINO'), findsOneWidget);
    expect(find.textContaining('v1.0.0'), findsOneWidget);
  });

  testWidgets('SettingsPage toggling switch updates settings', (tester) async {
    final cubit = SettingsCubit(
      repository: mockRepo,
      ttsService: mockTts,
      audioService: mockAudio,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(cubit: cubit),
      ),
    );
    await tester.pumpAndSettle();

    final sfxSwitchFinder = find.widgetWithText(SwitchListTile, 'Âm thanh còi & tiếng bíp (SFX)');
    expect(sfxSwitchFinder, findsOneWidget);

    await tester.tap(sfxSwitchFinder);
    await tester.pumpAndSettle();

    expect(mockRepo.settings.isSfxEnabled, false);
  });
}

