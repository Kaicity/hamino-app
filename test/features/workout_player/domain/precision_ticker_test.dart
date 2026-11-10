import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/features/workout_player/domain/services/precision_ticker.dart';

void main() {
  group('PrecisionTicker Tests (TASK-3.1)', () {
    test('tick emits DateTime stream at specified interval', () async {
      const ticker = PrecisionTicker();
      final ticks = await ticker
          .tick(interval: const Duration(milliseconds: 20))
          .take(3)
          .toList();

      expect(ticks.length, 3);
      expect(ticks[0], isA<DateTime>());
      expect(ticks[1].isAfter(ticks[0]), isTrue);
      expect(ticks[2].isAfter(ticks[1]), isTrue);
    });
  });
}

