import 'dart:async';
import 'package:flutter/foundation.dart';

import 'audio_focus_service.dart';
import 'audio_service_interface.dart';
import 'tts_service_interface.dart';
import '../../features/workout_player/presentation/bloc/workout_player_state.dart';

/// Bộ điều phối âm thanh (Audio Cue Manager)
/// Tự động lắng nghe trạng thái của WorkoutPlayer và kích hoạt còi hiệu, tiếng bíp SFX, giọng đọc Huấn luyện viên
class AudioCueManager {
  final IAudioService audioService;
  final ITtsService ttsService;
  final AudioFocusService? audioFocusService;

  StreamSubscription<WorkoutPlayerState>? _blocSubscription;

  bool isSfxEnabled = true;
  bool isTtsEnabled = true;
  String language = 'vi-VN';
  Duration defaultVoiceDelay = const Duration(milliseconds: 500);

  // Biến theo dõi tránh phát trùng lặp
  String? _lastStepId;
  int? _lastCountdownSecond;
  bool _restWarningAnnounced = false;
  bool _completedAnnounced = false;
  bool _isDisposed = false;

  AudioCueManager({
    required this.audioService,
    required this.ttsService,
    this.audioFocusService,
    Duration? defaultVoiceDelay,
  }) : defaultVoiceDelay = defaultVoiceDelay ?? const Duration(milliseconds: 500);

  /// Khởi tạo tài nguyên âm thanh & TTS
  Future<void> initialize() async {
    await audioService.initialize();
    await ttsService.initialize();
    await audioFocusService?.initialize();
  }

  /// Lắng nghe State Stream từ WorkoutPlayerBloc
  StreamSubscription<WorkoutPlayerState> attach(Stream<WorkoutPlayerState> stream) {
    _blocSubscription?.cancel();
    _blocSubscription = stream.listen(handleState);
    return _blocSubscription!;
  }

  /// Đặt lại trạng thái bộ điều phối khi bắt đầu bài tập mới
  void reset() {
    _lastStepId = null;
    _lastCountdownSecond = null;
    _restWarningAnnounced = false;
    _completedAnnounced = false;
  }

  /// Xử lý State chuyển đổi từ BLoC
  Future<void> handleState(WorkoutPlayerState state) async {
    if (_isDisposed) return;

    if (state is PlayerInitial) {
      reset();
      return;
    }

    if (state is PlayerPaused) {
      await _handlePaused();
      return;
    }

    if (state is PlayerPrepare) {
      await _handlePrepare(state);
    } else if (state is PlayerWork) {
      await _handleWork(state);
    } else if (state is PlayerRest) {
      await _handleRest(state);
    } else if (state is PlayerCompleted) {
      await _handleCompleted(state);
    }
  }

  Future<void> _handlePaused() async {
    await ttsService.stop();
    await audioFocusService?.deactivate();
  }

  Future<void> _handlePrepare(PlayerPrepare state) async {
    final stepId = 'prepare_${state.currentRound}_${state.currentExerciseIndex}';

    // Bắt đầu chuẩn bị
    if (_lastStepId != stepId) {
      _lastStepId = stepId;
      _lastCountdownSecond = null;

      final exName = state.currentExercise?.name ?? state.workout?.name ?? '';
      final phrase = language.startsWith('en')
          ? 'Get ready: $exName'
          : 'Chuẩn bị: $exName';

      await _speakWithFocus(phrase);
    }

    // Đếm ngược 3 giây cuối (3, 2, 1)
    await _checkCountdownBeep(state.remainingSeconds);
  }

  Future<void> _handleWork(PlayerWork state) async {
    final stepId = 'work_${state.currentRound}_${state.currentExerciseIndex}';

    // Bắt đầu hiệp mới
    if (_lastStepId != stepId) {
      _lastStepId = stepId;
      _lastCountdownSecond = null;

      final phrase = language.startsWith('en')
          ? 'Round ${state.currentRound}, start!'
          : 'Hiệp ${state.currentRound}, bắt đầu!';

      await _playSfxAndVoice(
        sfxAction: () => audioService.playWhistleStart(),
        voiceText: phrase,
        delayBeforeVoice: defaultVoiceDelay > Duration.zero
            ? const Duration(milliseconds: 550)
            : Duration.zero,
      );
    }

    // Nếu động tác là Giữ tĩnh (Hold) -> đếm ngược 3 giây cuối
    if (state.currentExercise?.isStaticHold == true) {
      await _checkCountdownBeep(state.remainingSeconds);
    }
  }

  Future<void> _handleRest(PlayerRest state) async {
    final stepId = 'rest_${state.currentRound}_${state.currentExerciseIndex}_${state.nextRound}_${state.nextExerciseIndex}';

    // Bắt đầu nghỉ
    if (_lastStepId != stepId) {
      _lastStepId = stepId;
      _lastCountdownSecond = null;
      _restWarningAnnounced = false;

      final phrase = language.startsWith('en')
          ? 'Rest ${state.remainingSeconds} seconds'
          : 'Nghỉ ${state.remainingSeconds} giây';

      await _playSfxAndVoice(
        sfxAction: () => audioService.playChimeRest(),
        voiceText: phrase,
        delayBeforeVoice: defaultVoiceDelay > Duration.zero
            ? const Duration(milliseconds: 400)
            : Duration.zero,
      );
    }

    // Nhắc nhở sắp hết giờ nghỉ: đúng 10 giây cuối
    if (state.remainingSeconds == 10 && !_restWarningAnnounced) {
      _restWarningAnnounced = true;

      final nextName = state.nextExercise?.name ?? '';
      final phrase = language.startsWith('en')
          ? (nextName.isNotEmpty
              ? '10 seconds left, prepare $nextName'
              : '10 seconds left')
          : (nextName.isNotEmpty
              ? 'Còn 10 giây, chuẩn bị $nextName'
              : 'Còn 10 giây');

      await _playSfxAndVoice(
        sfxAction: () => audioService.playBeepShort(),
        voiceText: phrase,
        delayBeforeVoice: defaultVoiceDelay > Duration.zero
            ? const Duration(milliseconds: 250)
            : Duration.zero,
      );
    }

    // Đếm ngược 3 giây cuối
    await _checkCountdownBeep(state.remainingSeconds);
  }

  Future<void> _handleCompleted(PlayerCompleted state) async {
    if (_completedAnnounced) return;
    _completedAnnounced = true;
    _lastStepId = 'completed';

    final phrase = language.startsWith('en')
        ? 'Congratulations, outstanding workout completed!'
        : 'Chúc mừng bạn đã hoàn thành bài tập xuất sắc!';

    await _playSfxAndVoice(
      sfxAction: () => audioService.playVictoryFanfare(),
      voiceText: phrase,
      delayBeforeVoice: defaultVoiceDelay > Duration.zero
          ? const Duration(milliseconds: 1400)
          : Duration.zero,
    );
  }

  /// Logic kiểm tra và phát tiếng bíp đếm ngược 3, 2, 1
  /// Đảm bảo không overlap: nếu TTS đang đọc thì dừng TTS để tiếng bíp nghe rõ tức thì
  Future<void> _checkCountdownBeep(int remainingSeconds) async {
    if (remainingSeconds >= 1 && remainingSeconds <= 3) {
      if (_lastCountdownSecond != remainingSeconds) {
        _lastCountdownSecond = remainingSeconds;

        if (isSfxEnabled) {
          // Dừng TTS để âm đếm ngược không bị che lấp
          await ttsService.stop();
          await audioFocusService?.deactivate();
          await audioService.playBeepHigh();
        }
      }
    }
  }

  /// Phát SFX trước, sau đó phát Voice kèm Audio Focus Ducking
  Future<void> _playSfxAndVoice({
    required Future<void> Function() sfxAction,
    required String voiceText,
    required Duration delayBeforeVoice,
  }) async {
    try {
      if (isSfxEnabled) {
        await sfxAction();
      }

      if (isTtsEnabled && voiceText.isNotEmpty) {
        if (isSfxEnabled && delayBeforeVoice > Duration.zero) {
          await Future.delayed(delayBeforeVoice);
        }
        await _speakWithFocus(voiceText);
      }
    } catch (e) {
      debugPrint('[AudioCueManager] Error in _playSfxAndVoice: $e');
    }
  }

  /// Nói với cơ chế Audio Focus Ducking: giảm nhạc nền, đọc khẩu lệnh, khôi phục nhạc nền
  Future<void> _speakWithFocus(String text) async {
    if (!isTtsEnabled || text.trim().isEmpty) return;

    try {
      await audioFocusService?.activate();
      await ttsService.speak(text, awaitCompletion: true);
    } catch (e) {
      debugPrint('[AudioCueManager] Error speaking with focus: $e');
    } finally {
      await audioFocusService?.deactivate();
    }
  }

  /// Hủy tài nguyên khi thoát
  Future<void> dispose() async {
    _isDisposed = true;
    await _blocSubscription?.cancel();
    _blocSubscription = null;
    await audioService.stop();
    await ttsService.stop();
    await audioFocusService?.deactivate();
  }
}
