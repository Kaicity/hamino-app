import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Lớp phủ khóa màn hình cảm ứng, mở khóa bằng cách nhấn giữ 2 giây
class LockOverlay extends StatefulWidget {
  final VoidCallback onUnlock;

  const LockOverlay({super.key, required this.onUnlock});

  @override
  State<LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<LockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onUnlock();
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    _animController.forward(from: 0.0);
  }

  void _onPressEnd() {
    if (_animController.status != AnimationStatus.completed) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTapDown: (_) => _onPressStart(),
              onTapUp: (_) => _onPressEnd(),
              onTapCancel: _onPressEnd,
              onLongPress: () {
                // Đảm bảo mở khóa khi trigger longpress
                widget.onUnlock();
              },
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: _animController.value > 0
                              ? _animController.value
                              : 0.0,
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.prepareYellow),
                          backgroundColor: AppColors.borderDark,
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.prepareYellow.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 38,
                          color: AppColors.prepareYellow,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'MÀN HÌNH ĐANG KHÓA',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textWhite,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn giữ nút khóa 2 giây để mở khóa',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

