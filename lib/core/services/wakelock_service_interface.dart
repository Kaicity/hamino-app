/// Giao diện quản lý trạng thái giữ sáng màn hình khi tập luyện
abstract class IWakelockService {
  Future<void> enable();
  Future<void> disable();
  Future<bool> isEnabled();
}

