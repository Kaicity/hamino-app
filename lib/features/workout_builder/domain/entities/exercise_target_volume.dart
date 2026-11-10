import 'package:equatable/equatable.dart';

import 'exercise_entity.dart';

/// Đại diện cho khối lượng mục tiêu chi tiết của từng động tác qua toàn bộ các hiệp
/// Thay vì cộng dồn chung các động tác khác nhau thành 1 số reps vô nghĩa,
/// đối tượng này tính toán và hiển thị riêng biệt theo từng động tác:
/// Ví dụ:
/// - "Push up: = 50 rep" (10 rep/hiệp × 5 hiệp)
/// - "Pull ups: = 100 rep" (20 rep/hiệp × 5 hiệp)
/// - "Plank: = 10 phút" (120s/hiệp × 5 hiệp)
/// - "Swat hold: = 5 phút" (60s/hiệp × 5 hiệp)
class ExerciseTargetVolume extends Equatable {
  final String exerciseName;
  final bool isStaticHold;
  final int repsPerRound;
  final int totalReps;
  final int holdSecondsPerRound;
  final int totalHoldSeconds;
  final int targetRounds;

  const ExerciseTargetVolume({
    required this.exerciseName,
    required this.isStaticHold,
    this.repsPerRound = 0,
    this.totalReps = 0,
    this.holdSecondsPerRound = 0,
    this.totalHoldSeconds = 0,
    required this.targetRounds,
  });

  /// Quy đổi tổng số giây giữ sang định dạng phút và giây
  /// Ví dụ: 600s -> "10 phút", 300s -> "5 phút", 90s -> "1 phút 30 giây", 45s -> "45 giây"
  String get formattedHoldTime {
    if (totalHoldSeconds <= 0) return '0 giây';
    if (totalHoldSeconds < 60) return '$totalHoldSeconds giây';

    final minutes = totalHoldSeconds ~/ 60;
    final seconds = totalHoldSeconds % 60;

    if (seconds == 0) {
      return '$minutes phút';
    }
    return '$minutes phút $seconds giây';
  }

  /// Chuỗi hiển thị mục tiêu cho động tác:
  /// Ví dụ: "= 50 rep", "= 100 rep", "= 10 phút", "= 5 phút"
  String get targetDisplay {
    if (isStaticHold) {
      return '= $formattedHoldTime';
    }
    return '= $totalReps rep';
  }

  /// Chuỗi công thức chi tiết:
  /// Ví dụ: "10 rep/hiệp × 5 hiệp" hoặc "60s/hiệp × 5 hiệp"
  String get calculationFormula {
    if (isStaticHold) {
      return '${holdSecondsPerRound}s/hiệp × $targetRounds hiệp';
    }
    return '$repsPerRound rep/hiệp × $targetRounds hiệp';
  }

  /// Chuỗi hiển thị tóm tắt đầy đủ:
  /// Ví dụ: "Push up: = 50 rep" hoặc "Plank: = 10 phút"
  String get summaryLabel {
    return '$exerciseName: $targetDisplay';
  }

  /// Tính toán danh sách mục tiêu chi tiết từng động tác từ danh sách exercises và targetRounds.
  /// Gom nhóm (group) các động tác trùng tên để tính tổng số rep hoặc giây giữ của động tác đó.
  static List<ExerciseTargetVolume> fromExercises({
    required List<ExerciseEntity> exercises,
    required int targetRounds,
  }) {
    if (exercises.isEmpty || targetRounds <= 0) {
      return const [];
    }

    final Map<String, _VolumeAccumulator> groupMap = {};
    final List<String> orderedKeys = [];

    for (final ex in exercises) {
      final key = ex.name.trim().toLowerCase();
      if (!groupMap.containsKey(key)) {
        groupMap[key] = _VolumeAccumulator(
          displayName: ex.name.trim(),
          isStaticHold: ex.isStaticHold,
        );
        orderedKeys.add(key);
      }

      final acc = groupMap[key]!;
      acc.repsPerRound += ex.defaultReps;
      acc.holdSecondsPerRound += ex.holdSeconds;
      if (ex.isStaticHold) {
        acc.isStaticHold = true;
      }
    }

    return orderedKeys.map((key) {
      final acc = groupMap[key]!;
      return ExerciseTargetVolume(
        exerciseName: acc.displayName,
        isStaticHold: acc.isStaticHold,
        repsPerRound: acc.repsPerRound,
        totalReps: acc.repsPerRound * targetRounds,
        holdSecondsPerRound: acc.holdSecondsPerRound,
        totalHoldSeconds: acc.holdSecondsPerRound * targetRounds,
        targetRounds: targetRounds,
      );
    }).toList();
  }

  @override
  List<Object?> get props => [
        exerciseName,
        isStaticHold,
        repsPerRound,
        totalReps,
        holdSecondsPerRound,
        totalHoldSeconds,
        targetRounds,
      ];
}

class _VolumeAccumulator {
  final String displayName;
  bool isStaticHold;
  int repsPerRound = 0;
  int holdSecondsPerRound = 0;

  _VolumeAccumulator({
    required this.displayName,
    required this.isStaticHold,
  });
}

