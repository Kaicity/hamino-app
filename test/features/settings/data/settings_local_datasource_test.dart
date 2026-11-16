import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:hamino_app/features/settings/domain/entities/user_settings_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsLocalDataSourceImpl dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getSettings returns default values when no prefs are saved', () async {
    final prefs = await SharedPreferences.getInstance();
    dataSource = SettingsLocalDataSourceImpl(prefs);

    final settings = await dataSource.getSettings();

    expect(settings.isTtsEnabled, true);
    expect(settings.ttsLanguage, 'vi-VN');
    expect(settings.speechRate, 0.52);
    expect(settings.isSfxEnabled, true);
    expect(settings.isAudioDuckingEnabled, true);
    expect(settings.isWakelockEnabled, true);
    expect(settings.defaultPrepareSeconds, 10);
  });

  test('saveSettings persists all values to SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    dataSource = SettingsLocalDataSourceImpl(prefs);

    const customSettings = UserSettingsEntity(
      isTtsEnabled: false,
      ttsLanguage: 'en-US',
      speechRate: 0.8,
      isSfxEnabled: false,
      isAudioDuckingEnabled: false,
      isWakelockEnabled: false,
      defaultPrepareSeconds: 15,
    );

    await dataSource.saveSettings(customSettings);

    final loaded = await dataSource.getSettings();
    expect(loaded.isTtsEnabled, false);
    expect(loaded.ttsLanguage, 'en-US');
    expect(loaded.speechRate, 0.8);
    expect(loaded.isSfxEnabled, false);
    expect(loaded.isAudioDuckingEnabled, false);
    expect(loaded.isWakelockEnabled, false);
    expect(loaded.defaultPrepareSeconds, 15);
  });
}

