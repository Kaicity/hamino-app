import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/audio_cue_manager.dart';
import '../../../../core/services/audio_service_interface.dart';
import '../../../../core/services/tts_service_interface.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../features/workout_builder/domain/entities/workout_category.dart';
import '../../../../features/workout_builder/domain/entities/workout_template_entity.dart';
import '../bloc/workout_player_bloc.dart';
import '../bloc/workout_player_event.dart';
import '../bloc/workout_player_state.dart';
import '../widgets/lock_overlay.dart';
import '../widgets/next_up_card.dart';
import '../widgets/workout_completed_view.dart';
import '../widgets/workout_progress_bar.dart';

/// Màn hình tập luyện toàn màn hình (Immersive Workout Player Screen)
class WorkoutPlayerPage extends StatelessWidget {
  final WorkoutTemplateEntity workout;

  const WorkoutPlayerPage({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutPlayerBloc>()..add(StartWorkoutEvent(workout)),
      child: const _WorkoutPlayerView(),
    );
  }
}

class _WorkoutPlayerView extends StatefulWidget {
  const _WorkoutPlayerView();

  @override
  State<_WorkoutPlayerView> createState() => _WorkoutPlayerViewState();
}

class _WorkoutPlayerViewState extends State<_WorkoutPlayerView> {
  late final AudioCueManager _audioCueManager;

  @override
  void initState() {
    super.initState();
    if (sl.isRegistered<AudioCueManager>()) {
      _audioCueManager = sl<AudioCueManager>();
    } else {
      _audioCueManager = AudioCueManager(
        audioService: const _NoOpAudioService(),
        ttsService: const _NoOpTtsService(),
      );
    }
    _audioCueManager.initialize();
  }

  @override
  void dispose() {
    _audioCueManager.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Dừng buổi tập?', style: AppTypography.headlineSmall),
        content: Text(
          'Tiến độ của buổi tập này sẽ kết thúc. Bạn có chắc muốn thoát không?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'TIẾP TỤC TẬP',
              style: AppTypography.labelMedium.copyWith(color: AppColors.workGreen),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'DỪNG & THOÁT',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Color _getBackgroundColor(WorkoutPlayerState state) {
    if (state is PlayerPrepare) {
      return const Color(0xFF2A2605); // Nền ánh vàng
    } else if (state is PlayerWork) {
      if (state.workout?.category == WorkoutCategory.emom) {
        return const Color(0xFF1F1005); // Nền ánh cam cho EMOM
      }
      return const Color(0xFF0D2818); // Nền ánh xanh lá
    } else if (state is PlayerRest) {
      return const Color(0xFF0A192F); // Nền ánh xanh dương
    } else if (state is PlayerPaused) {
      return const Color(0xFF1A1A1A); // Nền xám tối
    } else if (state is PlayerCompleted) {
      return AppColors.bgDark;
    }
    return AppColors.bgDark;
  }

  Color _getAccentColor(WorkoutPlayerState state) {
    if (state is PlayerPrepare) {
      return AppColors.prepareYellow;
    } else if (state is PlayerWork) {
      if (state.workout?.category == WorkoutCategory.emom) {
        return AppColors.workOrange;
      }
      return AppColors.workGreen;
    } else if (state is PlayerRest) {
      return AppColors.restBlue;
    } else if (state is PlayerPaused) {
      return AppColors.warningOrange;
    }
    return AppColors.workGreen;
  }

  String _getStatusLabel(WorkoutPlayerState state) {
    if (state is PlayerPrepare) return 'CHUẨN BỊ';
    if (state is PlayerWork) {
      final isHold = state.currentExercise?.isStaticHold ?? false;
      return isHold ? 'GIỮ TĨNH (HOLD)' : 'TẬP LUYỆN (WORK)';
    }
    if (state is PlayerRest) return 'NGHỈ HỒI PHỤC';
    if (state is PlayerPaused) return 'TẠM DỪNG';
    if (state is PlayerCompleted) return 'HOÀN THÀNH';
    return '';
  }

  String _getTimerDisplay(WorkoutPlayerState state) {
    if (state is PlayerPrepare) {
      return TimeFormatter.formatSeconds(state.remainingSeconds);
    }
    if (state is PlayerWork) {
      final isHold = state.currentExercise?.isStaticHold ?? false;
      return isHold
          ? TimeFormatter.formatSeconds(state.remainingSeconds)
          : TimeFormatter.formatSeconds(state.elapsedSeconds);
    }
    if (state is PlayerRest) {
      return TimeFormatter.formatSeconds(state.remainingSeconds);
    }
    if (state is PlayerPaused) {
      final prev = state.previousState;
      if (prev is PlayerWork && !(prev.currentExercise?.isStaticHold ?? false)) {
        return TimeFormatter.formatSeconds(prev.elapsedSeconds);
      }
      return TimeFormatter.formatSeconds(prev.remainingSeconds);
    }
    return '00:00';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutPlayerBloc, WorkoutPlayerState>(
      listener: (context, state) {
        _audioCueManager.handleState(state);
      },
      builder: (context, state) {
        final bloc = context.read<WorkoutPlayerBloc>();

        if (state is PlayerCompleted) {
          return Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              child: WorkoutCompletedView(
                state: state,
                onFinish: () => Navigator.of(context).pop(),
              ),
            ),
          );
        }

        final bgColor = _getBackgroundColor(state);
        final accentColor = _getAccentColor(state);
        final statusLabel = _getStatusLabel(state);
        final timerText = _getTimerDisplay(state);
        final currentEx = state.currentExercise;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final shouldPop = await _confirmExit(context);
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // ── Top Header: Back button, Progress bar, Sound & Lock button ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Exit button
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppColors.textWhite, size: 26),
                              tooltip: 'Thoát',
                              onPressed: () async {
                                final shouldPop = await _confirmExit(context);
                                if (shouldPop && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),

                            // Round indicator (Header pill)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderDark),
                              ),
                              child: Text(
                                'HIỆP ${state.currentRound} / ${state.totalRounds}',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),

                            // Action buttons: Sound toggle & Screen Lock
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _audioCueManager.isSfxEnabled
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    color: _audioCueManager.isSfxEnabled
                                        ? AppColors.textWhite
                                        : AppColors.textMuted,
                                    size: 24,
                                  ),
                                  tooltip: _audioCueManager.isSfxEnabled
                                      ? 'Tắt âm thanh & HLV'
                                      : 'Bật âm thanh & HLV',
                                  onPressed: () {
                                    setState(() {
                                      final enabled = !_audioCueManager.isSfxEnabled;
                                      _audioCueManager.isSfxEnabled = enabled;
                                      _audioCueManager.isTtsEnabled = enabled;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    state.isScreenLocked
                                        ? Icons.lock_rounded
                                        : Icons.lock_open_rounded,
                                    color: state.isScreenLocked
                                        ? AppColors.prepareYellow
                                        : AppColors.textMuted,
                                    size: 24,
                                  ),
                                  tooltip: state.isScreenLocked
                                      ? 'Mở khóa màn hình'
                                      : 'Khóa màn hình cảm ứng',
                                  onPressed: () =>
                                      bloc.add(const ToggleScreenLockEvent()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Overall Progress Bar
                      if (state.workout != null)
                        WorkoutProgressBar(
                          workout: state.workout!,
                          totalElapsedSeconds: state.totalElapsedSeconds,
                          progress: state.overallProgress,
                        ),

                      const Spacer(),

                      // ── Center Section: Status, Giant Timer, Exercise Name ──
                      // Status Label Badge
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          statusLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Giant Timer Display (90sp+ Monospace)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            timerText,
                            style: AppTypography.timerBigDisplay.copyWith(
                              color: AppColors.textWhite,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Current Exercise Name & Targets
                      if (currentEx != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            currentEx.name,
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: 28,
                              color: AppColors.textWhite,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Text(
                            currentEx.targetSummary.toUpperCase(),
                            style: AppTypography.labelLarge.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        if (currentEx.notes != null &&
                            currentEx.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              currentEx.notes!,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          state.workout?.name ?? '',
                          style: AppTypography.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const Spacer(),

                      // ── Rest Extended Controls: +10s / +30s Nghỉ ─────────
                      if (state is PlayerRest) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionChip(
                              label: '+10s Nghỉ',
                              icon: Icons.add_rounded,
                              color: AppColors.restBlue,
                              onTap: () =>
                                  bloc.add(const AddRestTimeEvent(10)),
                            ),
                            const SizedBox(width: 14),
                            _actionChip(
                              label: '+30s Nghỉ',
                              icon: Icons.add_rounded,
                              color: AppColors.restBlue,
                              onTap: () =>
                                  bloc.add(const AddRestTimeEvent(30)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Control Bar: Previous, Big Play/Pause, Next ─────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Previous button
                            _controlCircleButton(
                              icon: Icons.skip_previous_rounded,
                              size: 58,
                              iconSize: 32,
                              color: AppColors.surfaceElevated,
                              iconColor: AppColors.textWhite,
                              tooltip: 'Quay lại',
                              onTap: () => bloc.add(const PreviousStepEvent()),
                            ),

                            const SizedBox(width: 28),

                            // Center Giant Play/Pause button (min 76x76)
                            _controlCircleButton(
                              icon: state is PlayerPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              size: 84,
                              iconSize: 50,
                              color: accentColor,
                              iconColor: accentColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              tooltip: state is PlayerPaused
                                  ? 'Tiếp tục'
                                  : 'Tạm dừng',
                              onTap: () {
                                if (state is PlayerPaused) {
                                  bloc.add(const ResumeWorkoutEvent());
                                } else {
                                  bloc.add(const PauseWorkoutEvent());
                                }
                              },
                            ),

                            const SizedBox(width: 28),

                            // Next / Skip button
                            _controlCircleButton(
                              icon: Icons.skip_next_rounded,
                              size: 58,
                              iconSize: 32,
                              color: AppColors.surfaceElevated,
                              iconColor: AppColors.textWhite,
                              tooltip: 'Xong / Bỏ qua',
                              onTap: () => bloc.add(const SkipNextEvent()),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Next Up Card ──────────────────────────────────────
                      NextUpCard(
                        nextExercise: state.nextExercise,
                        isLastStep: state.isLastStep,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),

                  // ── Screen Lock Overlay ──────────────────────────────────
                  if (state.isScreenLocked)
                    Positioned.fill(
                      child: LockOverlay(
                        onUnlock: () =>
                            bloc.add(const ToggleScreenLockEvent()),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlCircleButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required Color color,
    required Color iconColor,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _NoOpAudioService implements IAudioService {
  const _NoOpAudioService();

  @override
  Future<void> initialize() async {}
  @override
  Future<void> playBeepShort() async {}
  @override
  Future<void> playBeepHigh() async {}
  @override
  Future<void> playWhistleStart() async {}
  @override
  Future<void> playBellWork() async {}
  @override
  Future<void> playChimeRest() async {}
  @override
  Future<void> playVictoryFanfare() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

class _NoOpTtsService implements ITtsService {
  const _NoOpTtsService();

  @override
  Future<void> initialize() async {}
  @override
  Future<void> speak(String text, {bool awaitCompletion = false}) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> setLanguage(String languageCode) async {}
  @override
  Future<void> setSpeechRate(double rate) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> setPitch(double pitch) async {}
  @override
  Future<bool> isLanguageAvailable(String languageCode) async => true;
}


