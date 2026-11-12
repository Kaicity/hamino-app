import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/exercise_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Dialog/BottomSheet thêm hoặc chỉnh sửa một động tác trong bài tập
class ExerciseFormDialog extends StatefulWidget {
  final ExerciseEntity? exercise;
  final String workoutId;

  const ExerciseFormDialog({super.key, this.exercise, required this.workoutId});

  /// Mở dialog và trả về ExerciseEntity được tạo/chỉnh sửa, hoặc null nếu hủy
  static Future<ExerciseEntity?> show(
    BuildContext context, {
    ExerciseEntity? exercise,
    required String workoutId,
  }) {
    return showModalBottomSheet<ExerciseEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ExerciseFormDialog(exercise: exercise, workoutId: workoutId),
    );
  }

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _repsController;
  late final TextEditingController _holdController;
  late final TextEditingController _notesController;

  bool _isHoldMode = false;

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _isHoldMode = ex?.isStaticHold ?? false;
    _nameController = TextEditingController(text: ex?.name ?? '');
    _repsController = TextEditingController(
      text: (ex?.defaultReps ?? (_isHoldMode ? 0 : 10)).toString(),
    );
    _holdController = TextEditingController(
      text: (ex?.holdSeconds ?? (_isHoldMode ? 20 : 0)).toString(),
    );
    _notesController = TextEditingController(text: ex?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _repsController.dispose();
    _holdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _switchToRepsMode() {
    setState(() {
      _isHoldMode = false;
      if (int.tryParse(_repsController.text) == 0 ||
          _repsController.text.isEmpty) {
        _repsController.text = '10';
      }
      _holdController.text = '0';
    });
  }

  void _switchToHoldMode() {
    setState(() {
      _isHoldMode = true;
      if (int.tryParse(_holdController.text) == 0 ||
          _holdController.text.isEmpty) {
        _holdController.text = '20';
      }
      _repsController.text = '0';
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final reps = _isHoldMode ? 0 : (int.tryParse(_repsController.text) ?? 10);
    final hold = _isHoldMode
        ? (int.tryParse(_holdController.text) ?? 20)
        : (int.tryParse(_holdController.text) ?? 0);
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    const uuid = Uuid();
    final result = ExerciseEntity(
      id: widget.exercise?.id ?? uuid.v4(),
      workoutId: widget.workoutId,
      name: name,
      defaultReps: reps,
      holdSeconds: hold,
      orderIndex: widget.exercise?.orderIndex ?? 0,
      notes: notes,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.exercise != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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
              const SizedBox(height: 20),

              // Title
              Text(
                isEdit ? 'CHỈNH SỬA ĐỘNG TÁC' : 'THÊM ĐỘNG TÁC',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Tên động tác
              TextFormField(
                controller: _nameController,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textWhite,
                ),
                decoration: _inputDecoration(
                  'Tên động tác *',
                  Icons.fitness_center_outlined,
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập tên động tác';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Toggle mode: Reps / Hold
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _switchToRepsMode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isHoldMode
                                ? AppColors.workGreen.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(11),
                            ),
                            border: !_isHoldMode
                                ? Border.all(
                                    color: AppColors.workGreen,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.repeat_rounded,
                                size: 16,
                                color: !_isHoldMode
                                    ? AppColors.workGreen
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Theo số lần',
                                style: AppTypography.labelMedium.copyWith(
                                  color: !_isHoldMode
                                      ? AppColors.workGreen
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _switchToHoldMode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isHoldMode
                                ? AppColors.restBlue.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(11),
                            ),
                            border: _isHoldMode
                                ? Border.all(
                                    color: AppColors.restBlue,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: _isHoldMode
                                    ? AppColors.restBlue
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Theo giây',
                                style: AppTypography.labelMedium.copyWith(
                                  color: _isHoldMode
                                      ? AppColors.restBlue
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reps field (nếu không phải hold mode)
              if (!_isHoldMode) ...[
                TextFormField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                  ),
                  decoration: _inputDecoration(
                    'Số lần lặp (reps)',
                    Icons.repeat_rounded,
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) {
                      return 'Vui lòng nhập số lần hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _holdController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                  ),
                  decoration: _inputDecoration(
                    'Giây - tuỳ chọn, 0 để bỏ qua',
                    Icons.timer_outlined,
                  ),
                ),
              ],

              // Hold field (nếu ở hold mode)
              if (_isHoldMode) ...[
                TextFormField(
                  controller: _holdController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                  ),
                  decoration: _inputDecoration(
                    'Số giây *',
                    Icons.timer_outlined,
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) {
                      return 'Vui lòng nhập số giây hợp lệ';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 12),

              // Ghi chú
              TextFormField(
                controller: _notesController,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                ),
                decoration: _inputDecoration(
                  'Ghi chú kỹ thuật (tuỳ chọn)',
                  Icons.notes_outlined,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        side: const BorderSide(color: AppColors.borderDark),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'HỦY',
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
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.workGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'LƯU ĐỘNG TÁC',
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
      ),
    );
  }
}
