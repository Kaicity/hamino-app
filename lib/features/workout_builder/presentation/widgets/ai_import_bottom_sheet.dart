import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/ai_parsed_workout.dart';

/// Bottom sheet thông minh cho phép người dùng nhập ngữ cảnh hoặc dán danh sách bài tập thô,
/// sử dụng Gemini AI để đánh giá tính hợp lệ và tự động phân tích / tạo bài tập Calisthenics có cấu trúc.
class AiImportBottomSheet extends StatefulWidget {
  final Function(AiParsedWorkout parsedWorkout) onApply;

  const AiImportBottomSheet({super.key, required this.onApply});

  static Future<void> show(
    BuildContext context, {
    required Function(AiParsedWorkout parsedWorkout) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiImportBottomSheet(onApply: onApply),
    );
  }

  @override
  State<AiImportBottomSheet> createState() => _AiImportBottomSheetState();
}

class _AiImportBottomSheetState extends State<AiImportBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final IGeminiService _geminiService = sl<IGeminiService>();

  bool _isLoading = false;
  String? _errorMessage;
  String? _invalidContextReason;
  String? _currentApiKey;
  AiParsedWorkout? _parsedResult;

  static const String _sampleWorkoutText = '''CADIOR DAY - 4 SET
1. Nâng chân - 15 reps
2. Gập bụng ngược - 15 reps
3. Plank - 45 giây
4. Bicycle Crunch - 20 reps
5. Hollow Body Hold - 20
6. V-Up - 10-15 reps
7. Đá chân rung - 30 giây
8. Side Plank - 30 giây mỗi bên
9. Mountain Climber - 30 giây
10. Giữ nâng chân - 15-20 giây''';

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final key = await _geminiService.getApiKey();
    if (mounted) {
      setState(() {
        _currentApiKey = key;
      });
    }
  }

  Future<void> _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng dán danh sách bài tập hoặc nhập ngữ cảnh bài tập Calisthenics.';
        _invalidContextReason = null;
      });
      return;
    }

    if (text.length < 5) {
      setState(() {
        _errorMessage = 'Nội dung quá ngắn. Vui lòng cung cấp chi tiết hơn về danh sách hoặc yêu cầu bài tập Calisthenics.';
        _invalidContextReason = null;
      });
      return;
    }

    if (_currentApiKey == null || _currentApiKey!.isEmpty) {
      final keySet = await _showApiKeyDialog();
      if (!keySet) return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _invalidContextReason = null;
    });

    try {
      final result = await _geminiService.parseWorkoutText(rawText: text);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _parsedResult = result;
          _errorMessage = null;
          _invalidContextReason = null;
        });
      }
    } on InvalidWorkoutContextException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _invalidContextReason = e.message;
          _errorMessage = null;
          _parsedResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _invalidContextReason = null;
          _parsedResult = null;
        });
      }
    }
  }

  Future<bool> _showApiKeyDialog() async {
    final apiKeyController = TextEditingController(text: _currentApiKey ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.key_rounded, color: AppColors.workGreen, size: 22),
            const SizedBox(width: 8),
            Text('Cấu hình Gemini API Key', style: AppTypography.headlineSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Để AI phân tích tự động, ứng dụng cần Gemini API Key của Google (hoàn toàn miễn phí).',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: apiKeyController,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textWhite,
              ),
              decoration: InputDecoration(
                hintText: 'Dán Gemini API Key vào đây...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textDisabled,
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.workGreen,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '💡 Bạn có thể lấy Key miễn phí tại: aistudio.google.com',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.prepareYellow,
                fontSize: 11,
              ),
            ),
          ],
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
          ElevatedButton(
            onPressed: () async {
              final newKey = apiKeyController.text.trim();
              if (newKey.isNotEmpty) {
                await _geminiService.saveApiKey(newKey);
                if (mounted) {
                  setState(() {
                    _currentApiKey = newKey;
                  });
                }
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.workGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'LƯU KEY',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      _textController.text = data.text!.trim();
      setState(() {
        _errorMessage = null;
        _invalidContextReason = null;
      });
    }
  }

  void _loadSample() {
    _textController.text = _sampleWorkoutText;
    setState(() {
      _errorMessage = null;
      _invalidContextReason = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh kéo bar phía trên
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.workGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.workGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TẠO BÀI TẬP VỚI AI HAMI',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Phân tích & thiết kế giáo án Calisthenics',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.key_rounded,
                      color: _currentApiKey != null
                          ? AppColors.workGreen
                          : AppColors.warningOrange,
                      size: 22,
                    ),
                    tooltip: 'Cài đặt Gemini API Key',
                    onPressed: _showApiKeyDialog,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderDark, height: 1),

            // Content cuộn được
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _parsedResult == null
                    ? _buildInputView()
                    : _buildPreviewView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện nhập văn bản thô hoặc ngữ cảnh bài tập
  Widget _buildInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cảnh báo nếu chưa có API Key
        if (_currentApiKey == null || _currentApiKey!.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warningOrange.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warningOrange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chưa thiết lập Gemini API Key. Nhấn để cài đặt trước khi phân tích.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warningOrange,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showApiKeyDialog,
                  child: Text(
                    'CÀI ĐẶT',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warningOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Toolbar công cụ nhập
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NHẬP NGỮ CẢNH HOẶC DÁN BÀI TẬP:',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.1,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(
                    Icons.content_paste_rounded,
                    size: 14,
                    color: AppColors.restBlue,
                  ),
                  label: Text(
                    'Dán',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.restBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _loadSample,
                  icon: const Icon(
                    Icons.auto_fix_high_rounded,
                    size: 14,
                    color: AppColors.workGreen,
                  ),
                  label: Text(
                    'Ví dụ mẫu',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.workGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Ô nhập dữ liệu thô
        TextField(
          controller: _textController,
          maxLines: 8,
          onChanged: (_) {
            if (_errorMessage != null || _invalidContextReason != null) {
              setState(() {
                _errorMessage = null;
                _invalidContextReason = null;
              });
            }
          },
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textWhite,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: 'Ví dụ 1 (Dán danh sách bài tập):\nCADIOR DAY - 4 SET\n1. Nâng chân - 15 reps\n2. Plank - 45 giây\n3. Bicycle Crunch - 20 reps\n\nVí dụ 2 (Nhập ngữ cảnh muốn tập):\nBuổi tập Calisthenics ngực và tay sau 4 hiệp cho người mới bắt đầu tại công viên',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textDisabled,
              height: 1.3,
            ),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.workGreen,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),

        // Thông báo đặc biệt khi người dùng nhập ngữ cảnh không liên quan đến Calisthenics
        if (_invalidContextReason != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.errorRed.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.block_rounded,
                        color: AppColors.errorRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'NGỮ CẢNH KHÔNG LIÊN QUAN ĐẾN CALISTHENICS',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.errorRed,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _invalidContextReason!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textWhite,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.prepareYellow,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Gợi ý ngữ cảnh đúng:',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.prepareYellow,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• Dán danh sách bài tập thô (VD: Hít đất 15 reps, Plank 45s, Squat 20 cái...)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Hoặc nhập yêu cầu giáo án Calisthenics (VD: "Tập ngực và tay sau 4 hiệp tại nhà", "Bài tập bụng Calisthenics 15 phút").',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Thông báo lỗi khác nếu có
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.errorRed.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.errorRed,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Nút phân tích
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _analyzeText,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.workGreen,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.workGreen.withValues(
                alpha: 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI ĐANG PHÂN TÍCH NGỮ CẢNH...',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 22,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PHÂN TÍCH & TẠO BÀI TẬP VỚI AI',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Giao diện xem trước kết quả đã phân tích
  Widget _buildPreviewView() {
    final workout = _parsedResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thẻ tóm tắt thông tin bài tập được AI trích xuất
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.workGreen.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TÊN BÀI TẬP PHÂN TÍCH ĐƯỢC',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          workout.name,
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: workout.category.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: workout.category.color,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          workout.category.icon,
                          size: 14,
                          color: workout.category.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          workout.category.displayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: workout.category.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.borderDark, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoBadge(
                    icon: Icons.repeat_rounded,
                    label: 'Số hiệp',
                    value: '${workout.targetRounds} hiệp',
                    color: AppColors.workGreen,
                  ),
                  _infoBadge(
                    icon: Icons.hotel_rounded,
                    label: 'Nghỉ giữa hiệp',
                    value: '${workout.defaultRestSeconds}s',
                    color: AppColors.restBlue,
                  ),
                  _infoBadge(
                    icon: Icons.fitness_center_rounded,
                    label: 'Động tác',
                    value: '${workout.exercises.length} bài',
                    color: AppColors.prepareYellow,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DANH SÁCH ĐỘNG TÁC (${workout.exercises.length}):',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              'Có thể chỉnh sửa sau khi áp dụng',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Danh sách các động tác AI đã trích xuất
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workout.exercises.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final ex = workout.exercises[index];
            final isHold = ex.isHold;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  // Thứ tự
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.borderDark,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tên và ghi chú
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (ex.notes != null && ex.notes!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            ex.notes!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge Reps hoặc Giây
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isHold
                          ? AppColors.prepareYellow.withValues(alpha: 0.15)
                          : AppColors.workGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isHold
                            ? AppColors.prepareYellow
                            : AppColors.workGreen,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isHold ? Icons.timer_outlined : Icons.repeat_rounded,
                          size: 13,
                          color: isHold
                              ? AppColors.prepareYellow
                              : AppColors.workGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isHold
                              ? '${ex.holdSeconds}s'
                              : '${ex.defaultReps} reps',
                          style: AppTypography.labelSmall.copyWith(
                            color: isHold
                                ? AppColors.prepareYellow
                                : AppColors.workGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Hàng nút hành động
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _parsedResult = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'NHẬP LẠI',
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
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onApply(workout);
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.check_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                label: Text(
                  'ÁP DỤNG VÀO GIÁO ÁN',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.workGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
