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
  late final TextEditingController _roundsController;
  late final FocusNode _roundsFocusNode;
  String _workoutId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _roundsController = TextEditingController(text: '1');
    _roundsFocusNode = FocusNode();
    _roundsFocusNode.addListener(() {
      if (!_roundsFocusNode.hasFocus && mounted) {
        final n = int.tryParse(_roundsController.text);
        if (n == null || n <= 0) {
          final current = context.read<WorkoutBuilderBloc>().state.targetRounds;
          _roundsController.text = current.toString();
        }
      }
    });
    _workoutId = const Uuid().v4();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _roundsController.dispose();
    _roundsFocusNode.dispose();
    super.dispose();
  }

  void _syncControllersFromState(WorkoutBuilderState state) {
    if (_nameController.text != state.name) {
      _nameController.text = state.name;
      _nameController.selection = TextSelection.collapsed(
        offset: _nameController.text.length,
      );
    }
    final desc = state.description ?? '';
    if (_descController.text != desc) {
      _descController.text = desc;
      _descController.selection = TextSelection.collapsed(
        offset: _descController.text.length,
      );
    }
    if (!_roundsFocusNode.hasFocus &&
        _roundsController.text != state.targetRounds.toString()) {
      _roundsController.text = state.targetRounds.toString();
      _roundsController.selection = TextSelection.collapsed(
        offset: _roundsController.text.length,
      );
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
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textWhite,
              ),
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
                      icon: const Icon(
                        Icons.check_rounded,
                        color: AppColors.workGreen,
                        size: 20,
                      ),
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
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                  ),
                  decoration: _inputDecoration(
                    'Tên bài tập *',
                    Icons.title_rounded,
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) => bloc.add(UpdateNameEvent(v)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textWhite,
                  ),
                  decoration: _inputDecoration(
                    'Mô tả (tuỳ chọn)',
                    Icons.notes_outlined,
                  ),
                  maxLines: 3,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withValues(alpha: 0.2)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? cat.color
                                : AppColors.borderDark,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat.icon,
                              size: 16,
                              color: isSelected
                                  ? cat.color
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.displayName,
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected
                                    ? cat.color
                                    : AppColors.textMuted,
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
                Row(
                  children: [
                    _sectionTitle('NGHỈ GIỮA HIỆP'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: state.defaultRestSeconds > 0
                            ? AppColors.restBlue.withValues(alpha: 0.15)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatDurationFull(state.defaultRestSeconds),
                        style: AppTypography.labelSmall.copyWith(
                          color: state.defaultRestSeconds > 0
                              ? AppColors.restBlue
                              : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _restDurationSelector(
                  selected: state.defaultRestSeconds,
                  onSelected: (v) => bloc.add(UpdateDefaultRestSecondsEvent(v)),
                  onOpenCustom: () => _showCustomRestTimeSheet(
                    context,
                    state.defaultRestSeconds,
                    bloc,
                  ),
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
                      activeTrackColor: AppColors.workGreen.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.isTimeCapped
                            ? 'Có giới hạn (${_formatTimeCapFull(state.timeCapSeconds)})'
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
                    ),
                    if (state.isTimeCapped)
                      GestureDetector(
                        onTap: () => _showCustomTimeCapSheet(
                          context,
                          state.timeCapSeconds,
                          bloc,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.tune_rounded,
                                size: 14,
                                color: AppColors.warningOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tùy chỉnh',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.warningOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (state.isTimeCapped) ...[
                  const SizedBox(height: 8),
                  Slider(
                    value:
                        ((state.timeCapSeconds > 0
                                    ? state.timeCapSeconds
                                    : 1200) /
                                60)
                            .clamp(1.0, 120.0),
                    min: 1,
                    max: 120,
                    divisions: 119,
                    activeColor: AppColors.warningOrange,
                    inactiveColor: AppColors.borderDark,
                    label: _formatTimeCapFull(state.timeCapSeconds),
                    onChanged: (val) {
                      bloc.add(UpdateTimeCapSecondsEvent(val.round() * 60));
                    },
                  ),
                  const SizedBox(height: 4),
                  _timeCapSelector(
                    selected: state.timeCapSeconds,
                    onSelected: (v) => bloc.add(UpdateTimeCapSecondsEvent(v)),
                    onToggleOff: () =>
                        bloc.add(const ToggleTimeCapEvent(false)),
                    onOpenCustom: () => _showCustomTimeCapSheet(
                      context,
                      state.timeCapSeconds,
                      bloc,
                    ),
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
                      onTap: () {
                        if (state.targetRounds > 1) {
                          final next = state.targetRounds - 1;
                          bloc.add(UpdateTargetRoundsEvent(next));
                          _roundsController.text = next.toString();
                        }
                      },
                      enabled: state.targetRounds > 1,
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 80,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _roundsFocusNode.hasFocus
                              ? AppColors.workGreen
                              : AppColors.borderDark,
                          width: _roundsFocusNode.hasFocus ? 1.5 : 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _roundsController,
                        focusNode: _roundsFocusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.workGreen,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (val) {
                          final n = int.tryParse(val);
                          if (n != null && n > 0) {
                            bloc.add(UpdateTargetRoundsEvent(n));
                          }
                        },
                        onTapOutside: (_) => _roundsFocusNode.unfocus(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _roundButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        if (state.targetRounds < 100) {
                          final next = state.targetRounds + 1;
                          bloc.add(UpdateTargetRoundsEvent(next));
                          _roundsController.text = next.toString();
                        }
                      },
                      enabled: state.targetRounds < 100,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '/ hiệp',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

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
                        color: AppColors.borderDark,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fitness_center_outlined,
                            color: AppColors.textDisabled,
                            size: 40,
                          ),
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
                        onDismissed: (_) =>
                            bloc.add(RemoveExerciseEvent(index)),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.errorRed,
                            size: 24,
                          ),
                        ),
                        child: ExerciseListItem(
                          key: ValueKey(exercise.id),
                          exercise: exercise,
                          index: index,
                          workoutId: _workoutId,
                          onDelete: () async {
                            final confirmed = await _confirmDeleteExercise(
                              context,
                              exercise.name,
                            );
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
                        bloc.add(
                          AddExerciseEvent(
                            result.copyWith(
                              id: exerciseId,
                              orderIndex: state.exercises.length,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                      color: AppColors.workGreen,
                      size: 20,
                    ),
                    label: Text(
                      'THÊM ĐỘNG TÁC',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.workGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: AppColors.workGreen,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  static String _formatDurationShort(int seconds) {
    if (seconds <= 0) return '0s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}p';
    return '${m}p ${s}s';
  }

  static String _formatDurationFull(int seconds) {
    if (seconds <= 0) return 'Không nghỉ';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '$s giây';
    if (s == 0) return '$m phút';
    return '$m phút $s giây';
  }

  static String _formatTimeCapFull(int seconds) {
    if (seconds <= 0) return 'Không giới hạn';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '$s giây';
    if (s == 0) return '$m phút';
    return '$m phút $s giây';
  }

  void _showCustomRestTimeSheet(
    BuildContext context,
    int initialSeconds,
    WorkoutBuilderBloc bloc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomRestTimeSheet(
        initialSeconds: initialSeconds,
        onApply: (sec) => bloc.add(UpdateDefaultRestSecondsEvent(sec)),
      ),
    );
  }

  void _showCustomTimeCapSheet(
    BuildContext context,
    int initialSeconds,
    WorkoutBuilderBloc bloc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomTimeCapSheet(
        initialSeconds: initialSeconds,
        onApply: (sec) {
          if (sec <= 0) {
            bloc.add(const ToggleTimeCapEvent(false));
          } else {
            bloc.add(UpdateTimeCapSecondsEvent(sec));
          }
        },
      ),
    );
  }

  Widget _restDurationSelector({
    required int selected,
    required void Function(int) onSelected,
    required VoidCallback onOpenCustom,
  }) {
    const options = [0, 15, 30, 45, 60, 90, 120, 180];
    const labels = [
      'Không nghỉ',
      '15s',
      '30s',
      '45s',
      '60s',
      '90s',
      '2 phút',
      '3 phút',
    ];

    final isCustom = selected > 0 && !options.contains(selected);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...List.generate(options.length, (i) {
          final isSelected = selected == options[i];
          return GestureDetector(
            onTap: () {
              if (isSelected) {
                // Hủy chọn linh động -> trở về 0 (Không nghỉ)
                onSelected(0);
              } else {
                onSelected(options[i]);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.restBlue.withValues(alpha: 0.2)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.restBlue : AppColors.borderDark,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected && options[i] == 0) ...[
                    const Icon(
                      Icons.block_rounded,
                      size: 14,
                      color: AppColors.restBlue,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    labels[i],
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.restBlue
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Nút tùy chỉnh
        GestureDetector(
          onTap: onOpenCustom,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isCustom
                  ? AppColors.restBlue.withValues(alpha: 0.2)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCustom ? AppColors.restBlue : AppColors.borderDark,
                width: isCustom ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCustom ? Icons.tune_rounded : Icons.edit_outlined,
                  size: 14,
                  color: isCustom ? AppColors.restBlue : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  isCustom
                      ? 'Tùy chỉnh: ${_formatDurationShort(selected)}'
                      : 'Tùy chỉnh...',
                  style: AppTypography.labelMedium.copyWith(
                    color: isCustom ? AppColors.restBlue : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeCapSelector({
    required int selected,
    required void Function(int) onSelected,
    required VoidCallback onToggleOff,
    required VoidCallback onOpenCustom,
  }) {
    const options = [300, 600, 900, 1200, 1800, 2700, 3600];
    const labels = ['5p', '10p', '15p', '20p', '30p', '45p', '60p'];

    final isCustom = selected > 0 && !options.contains(selected);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...List.generate(options.length, (i) {
          final isSelected = selected == options[i];
          return GestureDetector(
            onTap: () {
              if (isSelected) {
                // Hủy chọn linh động -> tắt giới hạn thời gian
                onToggleOff();
              } else {
                onSelected(options[i]);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.warningOrange.withValues(alpha: 0.2)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.warningOrange
                      : AppColors.borderDark,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                labels[i],
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.warningOrange
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),

        // Nút tùy chỉnh
        GestureDetector(
          onTap: onOpenCustom,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isCustom
                  ? AppColors.warningOrange.withValues(alpha: 0.2)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCustom
                    ? AppColors.warningOrange
                    : AppColors.borderDark,
                width: isCustom ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCustom ? Icons.tune_rounded : Icons.edit_outlined,
                  size: 14,
                  color: isCustom
                      ? AppColors.warningOrange
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  isCustom
                      ? 'Tùy chỉnh: ${_formatDurationShort(selected)}'
                      : 'Tùy chỉnh...',
                  style: AppTypography.labelMedium.copyWith(
                    color: isCustom
                        ? AppColors.warningOrange
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

/// BottomSheet chọn thời gian nghỉ tùy chỉnh
class _CustomRestTimeSheet extends StatefulWidget {
  final int initialSeconds;
  final ValueChanged<int> onApply;

  const _CustomRestTimeSheet({
    required this.initialSeconds,
    required this.onApply,
  });

  @override
  State<_CustomRestTimeSheet> createState() => _CustomRestTimeSheetState();
}

class _CustomRestTimeSheetState extends State<_CustomRestTimeSheet> {
  late int _totalSeconds;
  late final TextEditingController _minController;
  late final TextEditingController _secController;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialSeconds;
    final m = _totalSeconds ~/ 60;
    final s = _totalSeconds % 60;
    _minController = TextEditingController(text: m.toString());
    _secController = TextEditingController(text: s.toString());
  }

  @override
  void dispose() {
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  void _syncFromControllers() {
    final m = int.tryParse(_minController.text) ?? 0;
    final s = int.tryParse(_secController.text) ?? 0;
    setState(() {
      _totalSeconds = (m * 60 + s).clamp(0, 3600);
    });
  }

  void _adjustSeconds(int delta) {
    final updated = (_totalSeconds + delta).clamp(0, 3600);
    setState(() {
      _totalSeconds = updated;
      _minController.text = (updated ~/ 60).toString();
      _secController.text = (updated % 60).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'THỜI GIAN NGHỈ TÙY CHỈNH',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Preview
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _totalSeconds > 0
                        ? AppColors.restBlue
                        : AppColors.borderDark,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _totalSeconds <= 0
                      ? 'Không nghỉ (0s)'
                      : '${_WorkoutBuilderViewState._formatDurationFull(_totalSeconds)} ($_totalSeconds giây)',
                  style: AppTypography.headlineSmall.copyWith(
                    color: _totalSeconds > 0
                        ? AppColors.restBlue
                        : AppColors.textWhite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Inputs row: Minutes : Seconds
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số phút',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textWhite,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.restBlue,
                              width: 1.5,
                            ),
                          ),
                          suffixText: 'phút',
                          suffixStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        onChanged: (_) => _syncFromControllers(),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Text(
                    ':',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số giây',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _secController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textWhite,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.restBlue,
                              width: 1.5,
                            ),
                          ),
                          suffixText: 'giây',
                          suffixStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        onChanged: (_) => _syncFromControllers(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick adjust chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickAdjustChip('-30s', () => _adjustSeconds(-30)),
                  _quickAdjustChip('-15s', () => _adjustSeconds(-15)),
                  _quickAdjustChip('-5s', () => _adjustSeconds(-5)),
                  _quickAdjustChip('+5s', () => _adjustSeconds(5)),
                  _quickAdjustChip('+15s', () => _adjustSeconds(15)),
                  _quickAdjustChip('+30s', () => _adjustSeconds(30)),
                  _quickAdjustChip('+60s', () => _adjustSeconds(60)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onApply(0);
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.borderDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'KHÔNG NGHỈ',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_totalSeconds);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.restBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'ÁP DỤNG',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAdjustChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// BottomSheet chọn giới hạn thời gian (Time Cap) tùy chỉnh
class _CustomTimeCapSheet extends StatefulWidget {
  final int initialSeconds;
  final ValueChanged<int> onApply;

  const _CustomTimeCapSheet({
    required this.initialSeconds,
    required this.onApply,
  });

  @override
  State<_CustomTimeCapSheet> createState() => _CustomTimeCapSheetState();
}

class _CustomTimeCapSheetState extends State<_CustomTimeCapSheet> {
  late int _totalSeconds;
  late final TextEditingController _minController;
  late final TextEditingController _secController;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialSeconds > 0 ? widget.initialSeconds : 1200;
    final m = _totalSeconds ~/ 60;
    final s = _totalSeconds % 60;
    _minController = TextEditingController(text: m.toString());
    _secController = TextEditingController(text: s.toString());
  }

  @override
  void dispose() {
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  void _syncFromControllers() {
    final m = int.tryParse(_minController.text) ?? 0;
    final s = int.tryParse(_secController.text) ?? 0;
    setState(() {
      _totalSeconds = (m * 60 + s).clamp(0, 7200);
    });
  }

  void _adjustMinutes(int deltaMinutes) {
    final updated = (_totalSeconds + deltaMinutes * 60).clamp(0, 7200);
    setState(() {
      _totalSeconds = updated;
      _minController.text = (updated ~/ 60).toString();
      _secController.text = (updated % 60).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GIỚI HẠN THỜI GIAN TÙY CHỈNH',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Preview
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _totalSeconds > 0
                        ? AppColors.warningOrange
                        : AppColors.borderDark,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _totalSeconds <= 0
                      ? 'Không giới hạn thời gian'
                      : '${_WorkoutBuilderViewState._formatTimeCapFull(_totalSeconds)} ($_totalSeconds giây)',
                  style: AppTypography.headlineSmall.copyWith(
                    color: _totalSeconds > 0
                        ? AppColors.warningOrange
                        : AppColors.textWhite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Inputs: Minutes : Seconds
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số phút',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textWhite,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.warningOrange,
                              width: 1.5,
                            ),
                          ),
                          suffixText: 'phút',
                          suffixStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        onChanged: (_) => _syncFromControllers(),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Text(
                    ':',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số giây',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _secController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textWhite,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.warningOrange,
                              width: 1.5,
                            ),
                          ),
                          suffixText: 'giây',
                          suffixStyle: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        onChanged: (_) => _syncFromControllers(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick adjust chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickAdjustChip('-10p', () => _adjustMinutes(-10)),
                  _quickAdjustChip('-5p', () => _adjustMinutes(-5)),
                  _quickAdjustChip('-1p', () => _adjustMinutes(-1)),
                  _quickAdjustChip('+1p', () => _adjustMinutes(1)),
                  _quickAdjustChip('+5p', () => _adjustMinutes(5)),
                  _quickAdjustChip('+10p', () => _adjustMinutes(10)),
                  _quickAdjustChip('+15p', () => _adjustMinutes(15)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onApply(0);
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.borderDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'BỎ GIỚI HẠN',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_totalSeconds);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warningOrange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'ÁP DỤNG',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAdjustChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
