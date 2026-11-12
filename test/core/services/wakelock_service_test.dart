import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/services/wakelock_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WakelockService Tests (TASK-5.1)', () {
    test('Default setting for keepScreenAwake should be true', () async {
      SharedPreferences.setMockInitialValues({});
      final service = WakelockService();

      final allowed = await service.isAllowedInSettings();
      expect(allowed, isTrue);
    });

    test('Updating setting to false should persist and be respected', () async {
      SharedPreferences.setMockInitialValues({});
      final service = WakelockService();

      await service.setAllowedInSettings(false);
      expect(await service.isAllowedInSettings(), isFalse);

      await service.setAllowedInSettings(true);
      expect(await service.isAllowedInSettings(), isTrue);
    });

    test('enable and disable execute safely without unhandled exception', () async {
      SharedPreferences.setMockInitialValues({});
      final service = WakelockService();

      // Trong môi trường headless test, WakelockPlus có thể ném MissingPluginException,
      // WakelockService phải bắt exception an toàn và không làm crash app.
      await service.enable();
      await service.disable();
      final status = await service.isEnabled();
      expect(status, isA<bool>());
    });
  });
}

