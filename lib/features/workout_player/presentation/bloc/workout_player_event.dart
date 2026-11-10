import 'package:equatable/equatable.dart';

import '../../../../features/workout_builder/domain/entities/workout_template_entity.dart';

abstract class WorkoutPlayerEvent extends Equatable {
  const WorkoutPlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Khởi động buổi tập với giáo án đã chọn
class StartWorkoutEvent extends WorkoutPlayerEvent {
  final WorkoutTemplateEntity workout;
  const StartWorkoutEvent(this.workout);

  @override
  List<Object?> get props => [workout];
}

/// Nhịp đếm thời gian từ PrecisionTicker (mỗi 100ms)
class TimerTickEvent extends WorkoutPlayerEvent {
  final DateTime currentTime;
  const TimerTickEvent(this.currentTime);

  @override
  List<Object?> get props => [currentTime];
}

/// Tạm dừng buổi tập
class PauseWorkoutEvent extends WorkoutPlayerEvent {
  const PauseWorkoutEvent();
}

/// Tiếp tục buổi tập từ trạng thái tạm dừng
class ResumeWorkoutEvent extends WorkoutPlayerEvent {
  const ResumeWorkoutEvent();
}

/// Bỏ qua bước hiện tại hoặc đánh dấu hoàn thành sớm (Prepare -> Work, Work -> Rest, Rest -> Next Work)
class SkipNextEvent extends WorkoutPlayerEvent {
  const SkipNextEvent();
}

/// Quay lại động tác hoặc hiệp tập trước đó
class PreviousStepEvent extends WorkoutPlayerEvent {
  const PreviousStepEvent();
}

/// Cộng thêm thời gian nghỉ (10s hoặc 30s)
class AddRestTimeEvent extends WorkoutPlayerEvent {
  final int additionalSeconds;
  const AddRestTimeEvent(this.additionalSeconds);

  @override
  List<Object?> get props => [additionalSeconds];
}

/// Kết thúc sớm buổi tập có chủ đích
class FinishWorkoutEarlyEvent extends WorkoutPlayerEvent {
  const FinishWorkoutEarlyEvent();
}

/// Bật / Tắt chế độ Khóa màn hình chạm (Screen Lock)
class ToggleScreenLockEvent extends WorkoutPlayerEvent {
  const ToggleScreenLockEvent();
}

