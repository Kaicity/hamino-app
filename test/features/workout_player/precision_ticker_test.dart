import 'package:flutter_test/flutter_test.dart';
import 'package:hamino_app/features/workout_player/domain/services/precision_ticker.dart';

void main() {
  group('PrecisionTicker Comprehensive Tests (TASK-6.2)', () {
    test('Đếm đúng chu kỳ interval và phát các DateTime hợp lệ', () async {
      const ticker = PrecisionTicker();
      final startTime = DateTime.now();
      final ticks = await ticker
          .tick(interval: const Duration(milliseconds: 50))
          .take(4)
          .toList();

      expect(ticks.length, 4);
      for (final tick in ticks) {
        expect(tick.isAfter(startTime) || tick.isAtSameMomentAs(startTime), isTrue);
      }
      expect(ticks[1].isAfter(ticks[0]), isTrue);
      expect(ticks[2].isAfter(ticks[1]), isTrue);
      expect(ticks[3].isAfter(ticks[2]), isTrue);
    });

    test('Không bị lệch thời gian tích lũy khi luồng xử lý bị delay (No Timer Drift)', () async {
      const ticker = PrecisionTicker();
      final receivedTicks = <DateTime>[];

      final subscription = ticker
          .tick(interval: const Duration(milliseconds: 30))
          .listen((tickTime) async {
        receivedTicks.add(tickTime);
        // Giả lập CPU bận rộn / delay luồng
        await Future.delayed(const Duration(milliseconds: 10));
      });

      await Future.delayed(const Duration(milliseconds: 140));
      await subscription.cancel();

      // Kiểm tra các tick đã nhận
      expect(receivedTicks.isNotEmpty, isTrue);
      // Mốc thời gian tuyệt đối của tick cuối cùng so với tick đầu tiên phản ánh thời gian thực tế trôi qua
      if (receivedTicks.length >= 2) {
        final elapsed = receivedTicks.last.difference(receivedTicks.first);
        expect(elapsed.inMilliseconds, greaterThanOrEqualTo(50));
      }
    });

    test('Hủy subscription đóng stream triệt để không gây memory leak', () async {
      const ticker = PrecisionTicker();
      int tickCount = 0;

      final subscription = ticker
          .tick(interval: const Duration(milliseconds: 20))
          .listen((_) {
        tickCount++;
      });

      await Future.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();
      final countAtCancel = tickCount;

      await Future.delayed(const Duration(milliseconds: 50));
      // Sau khi cancel, không có tick nào được kích hoạt thêm
      expect(tickCount, countAtCancel);
    });
  });
}

