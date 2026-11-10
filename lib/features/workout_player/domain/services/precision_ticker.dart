import 'dart:async';

/// Dịch vụ đồng hồ đếm nhịp độ chính xác cao (High-Precision Ticker)
/// Sử dụng stream phát nhịp dựa trên mốc thời gian tuyệt đối (DateTime.now())
/// Triệt tiêu hiện tượng trôi thời gian (Timer Drift) do CPU throttling hoặc Doze mode.
class PrecisionTicker {
  const PrecisionTicker();

  /// Phát stream mốc thời gian đều đặn theo khoảng thời gian xác định (mặc định 100ms)
  Stream<DateTime> tick({
    Duration interval = const Duration(milliseconds: 100),
  }) {
    return Stream.periodic(interval, (_) => DateTime.now());
  }
}

