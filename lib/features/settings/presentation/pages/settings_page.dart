import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

/// Màn hình Cài đặt Hệ thống của ứng dụng Hamino Workout
class SettingsPage extends StatelessWidget {
  final SettingsCubit? cubit;

  const SettingsPage({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final instance = cubit ?? sl<SettingsCubit>();
        instance.loadSettings();
        return instance;
      },
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: Text(
          'CÀI ĐẶT HỆ THỐNG',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textWhite,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.workGreen),
            );
          }

          final cubit = context.read<SettingsCubit>();
          final settings = state.settings;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // ── NHÓM 1: ÂM THANH & HUẤN LUYỆN VIÊN ──────────────────────
              _buildSectionHeader('ÂM THANH & HUẤN LUYỆN VIÊN (AUDIO & COACH)'),
              const SizedBox(height: 8),

              // Switch TTS
              _buildCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.record_voice_over_rounded,
                      iconColor: AppColors.workGreen,
                      title: 'Giọng đọc Trợ lý ảo (TTS)',
                      subtitle:
                          'HLV đọc tên động tác, số hiệp và cảnh báo giờ nghỉ',
                      value: settings.isTtsEnabled,
                      onChanged: (val) => cubit.updateTtsEnabled(val),
                    ),

                    if (settings.isTtsEnabled) ...[
                      const Divider(color: AppColors.borderDark, height: 1),
                      const SizedBox(height: 12),

                      // Lựa chọn ngôn ngữ
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ngôn ngữ giọng đọc',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildChoiceChip(
                                    label: '🇻🇳 Tiếng Việt',
                                    isSelected: settings.ttsLanguage == 'vi-VN',
                                    onTap: () => cubit.updateLanguage('vi-VN'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildChoiceChip(
                                    label: '🇺🇸 English',
                                    isSelected: settings.ttsLanguage == 'en-US',
                                    onTap: () => cubit.updateLanguage('en-US'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tốc độ giọng đọc (Speech Rate) Slider & Nút Nghe Thử
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tốc độ giọng đọc',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.borderDark,
                                    ),
                                  ),
                                  child: Text(
                                    '${settings.speechRate.toStringAsFixed(2)}x',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.workGreen,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.workGreen,
                                inactiveTrackColor: AppColors.borderDark,
                                thumbColor: AppColors.workGreen,
                                overlayColor: AppColors.workGreen.withValues(
                                  alpha: 0.2,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: settings.speechRate.clamp(0.3, 1.0),
                                min: 0.3,
                                max: 1.0,
                                divisions: 14,
                                onChanged: (val) => cubit.updateSpeechRate(val),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Nút Nghe thử mẫu
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: state.isTestingVoice
                                    ? null
                                    : () => cubit.testVoiceSample(),
                                icon: state.isTestingVoice
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.workGreen,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.volume_up_rounded,
                                        size: 18,
                                        color: AppColors.workGreen,
                                      ),
                                label: Text(
                                  state.isTestingVoice
                                      ? 'Đang đọc thử...'
                                      : 'Nghe thử giọng mẫu',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: state.isTestingVoice
                                        ? AppColors.textMuted
                                        : AppColors.workGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SFX & Audio Ducking
              _buildCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.notifications_active_rounded,
                      iconColor: AppColors.warningOrange,
                      title: 'Âm thanh còi & tiếng bíp (SFX)',
                      subtitle:
                          'Còi xuất phát, bíp đếm ngược 3-2-1, chuông báo nghỉ',
                      value: settings.isSfxEnabled,
                      onChanged: (val) => cubit.updateSfxEnabled(val),
                    ),
                    const Divider(color: AppColors.borderDark, height: 1),
                    _buildSwitchTile(
                      icon: Icons.music_note_rounded,
                      iconColor: AppColors.restBlue,
                      title: 'Tự động giảm âm nhạc ngoài (Audio Ducking)',
                      subtitle: 'Giảm âm lượng Spotify/Apple Music khi Hamino phát khẩu lệnh',
                      value: settings.isAudioDuckingEnabled,
                      onChanged: (val) => cubit.updateAudioDuckingEnabled(val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── NHÓM 2: MÀN HÌNH & HIỆU NĂNG ────────────────────────────
              _buildSectionHeader('MÀN HÌNH & PIN (DISPLAY & BATTERY)'),
              const SizedBox(height: 8),

              _buildCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.lightbulb_rounded,
                      iconColor: AppColors.prepareYellow,
                      title: 'Luôn giữ sáng màn hình (Wakelock)',
                      subtitle:
                          'Ngăn điện thoại tắt màn hình trong suốt buổi tập',
                      value: settings.isWakelockEnabled,
                      onChanged: (val) => cubit.updateWakelockEnabled(val),
                    ),
                    const Divider(color: AppColors.borderDark, height: 1),
                    const SizedBox(height: 12),

                    // Đếm ngược chuẩn bị mặc định
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thời gian đếm chuẩn bị mặc định',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thời gian chuẩn bị trước khi bước vào động tác đầu tiên',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildChoiceChip(
                                  label: '5 giây',
                                  isSelected:
                                      settings.defaultPrepareSeconds == 5,
                                  onTap: () =>
                                      cubit.updateDefaultPrepareSeconds(5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildChoiceChip(
                                  label: '10 giây (Chuẩn)',
                                  isSelected:
                                      settings.defaultPrepareSeconds == 10,
                                  onTap: () =>
                                      cubit.updateDefaultPrepareSeconds(10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildChoiceChip(
                                  label: '15 giây',
                                  isSelected:
                                      settings.defaultPrepareSeconds == 15,
                                  onTap: () =>
                                      cubit.updateDefaultPrepareSeconds(15),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── NHÓM 3: GIỚI THIỆU & THÔNG TIN ─────────────────────────
              _buildSectionHeader('GIỚI THIỆU (ABOUT HAMINO)'),
              const SizedBox(height: 8),

              _buildCard(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.workGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'HAMINO',
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: AppTypography.headlineSmall.copyWith(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Phiên bản v${AppConstants.appVersion}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.workGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Ứng dụng đếm giờ và quản lý giáo án tập luyện chuyên biệt tối ưu cho Calisthenics & Street Workout (Sets & Reps, EMOM, TABATA, AMRAP).',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textWhite,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Gửi lời tri ân sâu sắc tới cộng đồng Calisthenics Việt Nam & Thế giới. Stay Strong, Stay Discipline! 🏆',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textWhite,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Material(
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.workGreen,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.workGreen.withValues(alpha: 0.15)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.workGreen : AppColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.workGreen : AppColors.textWhite,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
