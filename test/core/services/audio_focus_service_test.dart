import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/services/audio_focus_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioFocusService (TASK-4.4)', () {
    test('handles initialize, activate, deactivate gracefully', () async {
      final service = AudioFocusService();

      expect(service.isActive, false);

      // Unit test platform won't crash when invoking audio_session (caught gracefully)
      await service.initialize();
      await service.activate();
      await service.deactivate();

      expect(service.isActive, false);
    });
  });
}

