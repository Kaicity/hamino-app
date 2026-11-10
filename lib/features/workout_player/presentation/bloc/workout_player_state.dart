import 'package:equatable/equatable.dart';

import '../../../../features/workout_builder/domain/entities/exercise_entity.dart';
import '../../../../features/workout_builder/domain/entities/workout_template_entity.dart';

/// Lý do hoàn thành buổi tập
enum CompletionReason {
  allRoundsFinished,
  timeCapReached,
  finishedEarly,
}

abstract class WorkoutPlayerState extends Equatable {
  final WorkoutTemplateEntity? workout;
  final int currentRound;
  final int totalRounds;
  final int currentExerciseIndex;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int totalElapsedSeconds;
  final bool isScreenLocked;

  const WorkoutPlayerState({
    this.workout,
    this.currentRound = 1,
    this.totalRounds = 1,
    this.currentExerciseIndex = 0,
    this.remainingSeconds = 0,
    this.elapsedSeconds = 0,
    this.totalElapsedSeconds = 0,
    this.isScreenLocked = false,
  });

  /// Động tác hiện tại
  ExerciseEntity? get currentExercise {
    if (workout == null || workout!.exercises.isEmpty) return null;
    if (currentExerciseIndex >= 0 && currentExerciseIndex < workout!.exercises.length) {
      return workout!.exercises[currentExerciseIndex];
    }
    return null;
  }

  /// Động tác kế tiếp (để hiển thị Next Up)
  ExerciseEntity? get nextExercise {
    if (workout == null || workout!.exercises.isEmpty) return null;
    final exercises = workout!.exercises;

    // Nếu còn động tác trong hiệp hiện tại
    if (currentExerciseIndex + 1 < exercises.length) {
      return exercises[currentExerciseIndex + 1];
    }

    // Nếu là động tác cuối của hiệp nhưng chưa phải hiệp cuối -> động tác đầu của hiệp sau
    if (currentRound < totalRounds) {
      return exercises.first;
    }

    // Hiệp cuối, động tác cuối -> không còn động tác tiếp theo
    return null;
  }

  /// Kiểm tra có phải động tác cuối của hiệp
  bool get isLastExerciseInRound =>
      workout != null && currentExerciseIndex >= workout!.exercises.length - 1;

  /// Kiểm tra có phải hiệp cuối cùng
  bool get isLastRound => currentRound >= totalRounds;

  /// Đã đến động tác cuối cùng của hiệp cuối cùng
  bool get isLastStep => isLastExerciseInRound && isLastRound;

  /// Tỷ lệ tiến độ tổng thể (0.0 đến 1.0)
  double get overallProgress {
    if (workout == null) return 0.0;
    if (workout!.hasTimeCap && workout!.timeCapSeconds > 0) {
      return (totalElapsedSeconds / workout!.timeCapSeconds).clamp(0.0, 1.0);
    }
    final totalSteps = totalRounds * workout!.exercises.length;
    if (totalSteps <= 0) return 0.0;
    final currentStep = (currentRound - 1) * workout!.exercises.length + currentExerciseIndex;
    return (currentStep / totalSteps).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        workout,
        currentRound,
        totalRounds,
        currentExerciseIndex,
        remainingSeconds,
        elapsedSeconds,
        totalElapsedSeconds,
        isScreenLocked,
      ];
}

/// Trạng thái khởi tạo, chưa bấm bắt đầu
class PlayerInitial extends WorkoutPlayerState {
  const PlayerInitial({super.workout});
}

/// Trạng thái đếm ngược chuẩn bị vào tập (Prepare Countdown)
class PlayerPrepare extends WorkoutPlayerState {
  const PlayerPrepare({
    required super.workout,
    super.currentRound = 1,
    required super.totalRounds,
    super.currentExerciseIndex = 0,
    required super.remainingSeconds,
    super.elapsedSeconds = 0,
    super.totalElapsedSeconds = 0,
    super.isScreenLocked = false,
  });

  PlayerPrepare copyWith({
    int? remainingSeconds,
    int? elapsedSeconds,
    int? totalElapsedSeconds,
    bool? isScreenLocked,
  }) {
    return PlayerPrepare(
      workout: workout,
      currentRound: currentRound,
      totalRounds: totalRounds,
      currentExerciseIndex: currentExerciseIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
      isScreenLocked: isScreenLocked ?? this.isScreenLocked,
    );
  }
}

/// Trạng thái đang trong hiệp tập (Work State)
class PlayerWork extends WorkoutPlayerState {
  const PlayerWork({
    required super.workout,
    required super.currentRound,
    required super.totalRounds,
    required super.currentExerciseIndex,
    super.remainingSeconds = 0,
    required super.elapsedSeconds,
    required super.totalElapsedSeconds,
    super.isScreenLocked = false,
  });

  PlayerWork copyWith({
    int? currentRound,
    int? currentExerciseIndex,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? totalElapsedSeconds,
    bool? isScreenLocked,
  }) {
    return PlayerWork(
      workout: workout,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
      isScreenLocked: isScreenLocked ?? this.isScreenLocked,
    );
  }
}

/// Trạng thái đang nghỉ ngơi giữa các động tác hoặc giữa các hiệp (Rest State)
class PlayerRest extends WorkoutPlayerState {
  final int nextRound;
  final int nextExerciseIndex;

  const PlayerRest({
    required super.workout,
    required super.currentRound,
    required super.totalRounds,
    required super.currentExerciseIndex,
    required this.nextRound,
    required this.nextExerciseIndex,
    required super.remainingSeconds,
    super.elapsedSeconds = 0,
    required super.totalElapsedSeconds,
    super.isScreenLocked = false,
  });

  PlayerRest copyWith({
    int? currentRound,
    int? currentExerciseIndex,
    int? nextRound,
    int? nextExerciseIndex,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? totalElapsedSeconds,
    bool? isScreenLocked,
  }) {
    return PlayerRest(
      workout: workout,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      nextRound: nextRound ?? this.nextRound,
      nextExerciseIndex: nextExerciseIndex ?? this.nextExerciseIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalElapsedSeconds: totalElapsedSeconds ?? this.totalElapsedSeconds,
      isScreenLocked: isScreenLocked ?? this.isScreenLocked,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        nextRound,
        nextExerciseIndex,
      ];
}

/// Trạng thái tạm dừng buổi tập
class PlayerPaused extends WorkoutPlayerState {
  final WorkoutPlayerState previousState;

  const PlayerPaused({
    required this.previousState,
    required super.workout,
    required super.currentRound,
    required super.totalRounds,
    required super.currentExerciseIndex,
    required super.remainingSeconds,
    required super.elapsedSeconds,
    required super.totalElapsedSeconds,
    super.isScreenLocked = false,
  });

  PlayerPaused copyWith({
    bool? isScreenLocked,
  }) {
    return PlayerPaused(
      previousState: previousState,
      workout: workout,
      currentRound: currentRound,
      totalRounds: totalRounds,
      currentExerciseIndex: currentExerciseIndex,
      remainingSeconds: remainingSeconds,
      elapsedSeconds: elapsedSeconds,
      totalElapsedSeconds: totalElapsedSeconds,
      isScreenLocked: isScreenLocked ?? this.isScreenLocked,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        previousState,
      ];
}

/// Trạng thái hoàn thành buổi tập
class PlayerCompleted extends WorkoutPlayerState {
  final CompletionReason reason;
  final int completedRounds;
  final int totalWorkSeconds;

  const PlayerCompleted({
    required super.workout,
    required super.totalElapsedSeconds,
    required super.totalRounds,
    required this.reason,
    required this.completedRounds,
    required this.totalWorkSeconds,
  }) : super(
          currentRound: completedRounds,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        reason,
        completedRounds,
        totalWorkSeconds,
      ];
}
