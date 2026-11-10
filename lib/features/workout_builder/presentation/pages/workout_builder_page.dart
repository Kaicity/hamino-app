import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../bloc/workout_builder_bloc.dart';
import '../../domain/entities/workout_category.dart';
import '../../domain/entities/workout_template_entity.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/exercise_form_dialog.dart';
import '../widgets/exercise_list_item.dart';
import '../widgets/workout_target_summary_card.dart';

/// Màn hình tạo mới hoặc chỉnh sửa một bài tập
class WorkoutBuilderPage extends StatelessWidget {
  final WorkoutTemplateEntity? workout;

  const WorkoutBuilderPage({super.key, this.workout});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutBuilderBloc>()..add(InitBuilderEvent(workout)),
      child: _WorkoutBuilderView(isEditing: workout != null),
    );
  }
}

class _WorkoutBuilderView extends StatefulWidget {
  final bool isEditing;

  const _WorkoutBuilderView({required this.isEditing});

  @override
  State<_WorkoutBuilderView> createState() => _WorkoutBuilderViewState();
}

class _WorkoutBuilderViewState extends State<_WorkoutBuilderView> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  String _workoutId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _workoutId = const Uuid().v4();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _syncControllersFromState(WorkoutBuilderState state) {
    if (_nameController.text != state.name) {
      _nameController.text = state.name;
      _nameController.selection =
          TextSelection.collapsed(offset: _nameController.text.length);
    }
    final desc = state.description ?? '';
    if (_descController.text != desc) {
      _descController.text = desc;
      _descController.selection =
          TextSelection.collapsed(offset: _descController.text.length);
    }
    if (state.editingId != null && _workoutId != state.editingId!) {
      _workoutId = state.editingId!;
    }
  }

  Future<bool> _confirmDeleteExercise(BuildContext context, String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xóa động tác?', style: AppTypography.headlineSmall),
        content: Text(
          'Bạn có muốn xóa "$name" khỏi danh sách bài tập?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'HỦY',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'XÓA',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBuilderBloc, WorkoutBuilderState>(
      listener: (context, state) {
        _syncControllersFromState(state);

        if (state.isSaved) {
          Navigator.of(context).pop(true);
        } else if (state.errorMessage != null && !state.isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<WorkoutBuilderBloc>();
        _syncControllersFromState(state);

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textWhite),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.isEditing ? 'CHỈNH SỬA BÀI TẬP' : 'TẠO BÀI TẬP',
              style: AppTypography.headlineMedium,
            ),
            actions: [
              state.isSaving
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.workGreen,
                          ),
                        ),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: () => bloc.add(const SaveWorkoutEvent()),
                      icon: const Icon(Icons.check_rounded,
                          color: AppColors.workGreen, size: 20),
                      label: Text(
                        'LƯU',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.workGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: Thông tin bài tập ──────────────────────────
                _sectionTitle('THÔNG TIN BÀI TẬP'),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textWhite),
                  decoration: _inputDecoration('Tên bài tập *', Icons.title_rounded),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) => bloc.add(UpdateNameEvent(v)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textWhite),
                  decoration:
                      _inputDecoration('Mô tả (tuỳ chọn)', Icons.notes_outlined),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (v) => bloc.add(UpdateDescriptionEvent(v)),
                ),

                const SizedBox(height: 28),

                // ── Section 2: Thể loại ───────────────────────────────────
                _sectionTitle('THỂ LOẠI'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: WorkoutCategory.values.map((cat) {
                    final isSelected = state.category == cat;
                    return GestureDetector(
                      onTap: () => bloc.add(UpdateCategoryEvent(cat)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withValues(alpha: 0.2)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? cat.color : AppColors.borderDark,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon,
                                size: 16,
                                color: isSelected ? cat.color : AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              cat.displayName,
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected ? cat.color : AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // ── Section 3: Thời gian chuẩn bị ────────────────────────
                _sectionTitle('THỜI GIAN CHUẨN BỊ'),
                const SizedBox(height: 12),
                _choiceChipRow(
                  options: const [5, 10, 15],
                  labels: const ['5 giây', '10 giây', '15 giây'],
                  selected: state.prepareSeconds,
                  onSelected: (v) => bloc.add(UpdatePrepareSecondsEvent(v)),
                  activeColor: AppColors.prepareYellow,
                ),

                const SizedBox(height: 28),

                // ── Section 4: Nghỉ giữa hiệp ────────────────────────────
                _sectionTitle('NGHỈ GIỮA HIỆP'),
                const SizedBox(height: 12),
                _choiceChipRow(
                  options: const [30, 60, 90, 120, 180],
                  labels: const ['30s', '60s', '90s', '2 phút', '3 phút'],
                  selected: state.defaultRestSeconds,
                  onSelected: (v) => bloc.add(UpdateDefaultRestSecondsEvent(v)),
                  activeColor: AppColors.restBlue,
                ),

                const SizedBox(height: 28),

                // ── Section 5: Time Cap ───────────────────────────────────
                _sectionTitle('GIỚI HẠN THỜI GIAN (TIME CAP)'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: state.isTimeCapped,
                      onChanged: (v) => bloc.add(ToggleTimeCapEvent(v)),
                      activeThumbColor: AppColors.workGreen,
                      activeTrackColor: AppColors.workGreen.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.isTimeCapped
                          ? 'Có giới hạn (${state.timeCapSeconds ~/ 60} phút)'
                          : 'Không giới hạn thời gian',
                      style: AppTypography.bodyMedium.copyWith(
                        color: state.isTimeCapped
                            ? AppColors.textWhite
                            : AppColors.textMuted,
                        fontWeight: state.isTimeCapped
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (state.isTimeCapped) ...[
                  const SizedBox(height: 8),
                  Slider(
                    value: (state.timeCapSeconds ~/ 60)
                        .clamp(5, 60)
                        .toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    activeColor: AppColors.warningOrange,
                    inactiveColor: AppColors.borderDark,
                    label: '${state.timeCapSeconds ~/ 60} phút',
                    onChanged: (val) {
                      bloc.add(UpdateTimeCapSecondsEvent(val.round() * 60));
                    },
                  ),
                  const SizedBox(height: 4),
                  _choiceChipRow(
                    options: const [600, 900, 1200, 1800, 2700, 3600],
                    labels: const ['10p', '15p', '20p', '30p', '45p', '60p'],
                    selected: state.timeCapSeconds,
                    onSelected: (v) => bloc.add(UpdateTimeCapSecondsEvent(v)),
                    activeColor: AppColors.warningOrange,
                  ),
                ],

                const SizedBox(height: 28),

                // ── Section 6: Số hiệp mục tiêu ──────────────────────────
                _sectionTitle('SỐ HIỆP MỤC TIÊU'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _roundButton(
                      icon: Icons.remove_rounded,
                      onTap: () =>
                          bloc.add(UpdateTargetRoundsEvent(state.targetRounds - 1)),
                      enabled: state.targetRounds > 1,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${state.targetRounds}',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.workGreen,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'hiệp',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 20),
                    _roundButton(
                      icon: Icons.add_rounded,
                      onTap: () =>
                          bloc.add(UpdateTargetRoundsEvent(state.targetRounds + 1)),
                      enabled: state.targetRounds < 30,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Section 7: Danh sách động tác ────────────────────────
                _sectionTitle('DANH SÁCH ĐỘNG TÁC (${state.exercises.length})'),
                const SizedBox(height: 12),

                if (state.exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.borderDark, style: BorderStyle.solid),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.fitness_center_outlined,
                              color: AppColors.textDisabled, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có động tác nào',
                            style: AppTypography.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nhấn "THÊM ĐỘNG TÁC" để thiết kế giáo án',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.exercises.length,
                    onReorderItem: (oldIndex, newIndex) {
                      bloc.add(ReorderExercisesEvent(oldIndex, newIndex));
                    },
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 8,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final exercise = state.exercises[index];
                      return Dismissible(
                        key: ValueKey('dismiss_${exercise.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) =>
                            _confirmDeleteExercise(context, exercise.name),
                        onDismissed: (_) => bloc.add(RemoveExerciseEvent(index)),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.errorRed, size: 24),
                        ),
                        child: ExerciseListItem(
                          key: ValueKey(exercise.id),
                          exercise: exercise,
                          index: index,
                          workoutId: _workoutId,
                          onDelete: () async {
                            final confirmed = await _confirmDeleteExercise(
                                context, exercise.name);
                            if (confirmed) {
                              bloc.add(RemoveExerciseEvent(index));
                            }
                          },
                          onUpdate: (updated) =>
                              bloc.add(UpdateExerciseEvent(index, updated)),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 12),

                // Nút thêm động tác
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final exerciseId = const Uuid().v4();
                      final result = await ExerciseFormDialog.show(
                        context,
                        workoutId: _workoutId,
                      );
                      if (result != null) {
                        bloc.add(AddExerciseEvent(result.copyWith(
                          id: exerciseId,
                          orderIndex: state.exercises.length,
                        )));
                      }
                    },
                    icon: const Icon(Icons.add_rounded,
                        color: AppColors.workGreen, size: 20),
                    label: Text(
                      'THÊM ĐỘNG TÁC',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.workGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.workGreen, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Section 8: Kết quả mục tiêu bài tập ──────────────────
                _sectionTitle('KẾT QUẢ MỤC TIÊU BÀI TẬP'),
                const SizedBox(height: 12),
                WorkoutTargetSummaryCard(
                  exercises: state.exercises,
                  targetRounds: state.targetRounds,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _choiceChipRow({
    required List<int> options,
    required List<String> labels,
    required int selected,
    required void Function(int) onSelected,
    required Color activeColor,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final isSelected = selected == options[i];
        return GestureDetector(
          onTap: () => onSelected(options[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.2)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? activeColor : AppColors.borderDark,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              labels[i],
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? activeColor : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surfaceElevated : AppColors.borderDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.textWhite : AppColors.textDisabled,
          size: 20,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.workGreen, width: 1.5),
      ),
    );
  }
}
