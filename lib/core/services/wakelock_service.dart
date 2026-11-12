import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'wakelock_service_interface.dart';

/// Dịch vụ quản lý giữ sáng màn hình trong lúc tập luyện sử dụng [WakelockPlus]
class WakelockService implements IWakelockService {
  static const String prefKeyKeepAwake = 'pref_keep_screen_awake';
  final SharedPreferences? prefs;

  WakelockService({this.prefs});

  /// Kích hoạt giữ màn hình luôn sáng nếu người dùng cho phép trong cài đặt
  @override
  Future<void> enable() async {
    try {
      final allowed = await isAllowedInSettings();
      if (!allowed) {
        debugPrint('[WakelockService] Bị tắt bởi cấu hình người dùng');
        return;
      }
      await WakelockPlus.enable();
      debugPrint('[WakelockService] Đã bật giữ sáng màn hình');
    } catch (e) {
      debugPrint('[WakelockService] Không thể bật wakelock: $e');
    }
  }

  /// Tắt giữ màn hình, trả lại chế độ tự tắt màn hình bình thường của hệ điều hành
  @override
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
      debugPrint('[WakelockService] Đã tắt giữ sáng màn hình');
    } catch (e) {
      debugPrint('[WakelockService] Không thể tắt wakelock: $e');
    }
  }

  /// Kiểm tra trạng thái thực tế của màn hình (đang giữ sáng hay không)
  @override
  Future<bool> isEnabled() async {
    try {
      return await WakelockPlus.enabled;
    } catch (e) {
      debugPrint('[WakelockService] Lỗi kiểm tra trạng thái: $e');
      return false;
    }
  }

  /// Kiểm tra cấu hình người dùng có cho phép bật Wakelock không (mặc định là true)
  Future<bool> isAllowedInSettings() async {
    if (prefs != null) {
      return prefs!.getBool(prefKeyKeepAwake) ?? true;
    }
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getBool(prefKeyKeepAwake) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Cập nhật cấu hình người dùng cho phép hoặc không cho phép Wakelock
  Future<void> setAllowedInSettings(bool allowed) async {
    try {
      final sp = prefs ?? await SharedPreferences.getInstance();
      await sp.setBool(prefKeyKeepAwake, allowed);
      if (!allowed) {
        await disable();
      }
    } catch (e) {
      debugPrint('[WakelockService] Lỗi lưu cấu hình: $e');
    }
  }
}

