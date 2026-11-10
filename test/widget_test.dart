import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/core/utils/time_formatter.dart';
import 'package:hamino_app/main.dart';

void main() {
  group('Hamino Workout Phase 0 Smoke Tests', () {
    testWidgets('App renders branding and phase 0 banner', (WidgetTester tester) async {
      await tester.pumpWidget(const HaminoApp());

      expect(find.text('HAMINO'), findsOneWidget);
      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('PHASE 0 HOÀN TẤT'), findsOneWidget);
      expect(find.text('EMOM'), findsOneWidget);
      expect(find.text('ENDURANCE'), findsOneWidget);
      expect(find.text('SKILL'), findsOneWidget);
      expect(find.text('CARDIO'), findsOneWidget);
    });

    test('TimeFormatter formats seconds correctly', () {
      expect(TimeFormatter.formatSeconds(0), '00:00');
      expect(TimeFormatter.formatSeconds(45), '00:45');
      expect(TimeFormatter.formatSeconds(65), '01:05');
      expect(TimeFormatter.formatSeconds(120), '02:00');
      expect(TimeFormatter.formatSeconds(3665), '01:01:05');
    });

    test('TimeFormatter formatSecondsToReadable works as expected', () {
      expect(TimeFormatter.formatSecondsToReadable(30), '30s');
      expect(TimeFormatter.formatSecondsToReadable(60), '1m');
      expect(TimeFormatter.formatSecondsToReadable(90), '1m 30s');
      expect(TimeFormatter.formatSecondsToReadable(120), '2m');
    });
  });
}
