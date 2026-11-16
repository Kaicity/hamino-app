import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';
import '../../features/workout_builder/data/models/ai_parsed_workout.dart';

/// Interface cho dịch vụ AI Gemini
abstract class IGeminiService {
  Future<String?> getApiKey();
  Future<void> saveApiKey(String apiKey);
  Future<AiParsedWorkout> parseWorkoutText({
    required String rawText,
    String? customApiKey,
  });
}

/// Service tích hợp Google Gemini API để phân tích danh sách bài tập Calisthenics thô
class GeminiService implements IGeminiService {
  static const String _prefApiKey = 'hamino_gemini_api_key';

  // Model khuyến nghị: gemini-3.5-flash-lite (nhanh, rẻ, phản hồi chuẩn xác cho tác vụ trích xuất cấu trúc)
  static const String _defaultModel = 'gemini-3.5-flash-lite';

  final http.Client _client;

  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_prefApiKey);
    if (key != null && key.trim().isNotEmpty) {
      return key.trim();
    }
    return null;
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefApiKey, apiKey.trim());
  }

  @override
  Future<AiParsedWorkout> parseWorkoutText({
    required String rawText,
    String? customApiKey,
  }) async {
    final effectiveApiKey = customApiKey?.trim().isNotEmpty == true
        ? customApiKey!.trim()
        : await getApiKey();

    if (effectiveApiKey == null || effectiveApiKey.isEmpty) {
      throw Exception(
        'Chưa có Gemini API Key. Vui lòng cấu hình API Key trong mục cài đặt AI để tiếp tục.',
      );
    }

    final trimmedText = rawText.trim();
    if (trimmedText.isEmpty) {
      throw Exception(
        'Vui lòng nhập danh sách bài tập hoặc mô tả ngữ cảnh Calisthenics.',
      );
    }

    if (trimmedText.length < 5) {
      throw const InvalidWorkoutContextException(
        'Nội dung quá ngắn. Vui lòng cung cấp danh sách động tác hoặc ngữ cảnh bài tập Calisthenics chi tiết hơn.',
      );
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_defaultModel:generateContent?key=$effectiveApiKey',
    );

    final systemInstruction = '''
Bạn là chuyên gia huấn luyện viên Calisthenics và thể dục thể thao của ứng dụng Hamino.
Nhiệm vụ của bạn là kiểm tra ngữ cảnh văn bản do người dùng cung cấp và phân tích/tạo buổi tập Calisthenics.

QUY TẮC ĐÁNH GIÁ TÍNH HỢP LỆ CỦA NGỮ CẢNH (BẮT BUỘC TUÂN THỦ):
1. NGỮ CẢNH HỢP LỆ (isValid: true):
   - Người dùng dán danh sách bài tập thô (ví dụ: Push up, Pull up, Plank, Squat, Dips, Jumping Jack, Nâng chân, Gập bụng...), có thể viết tắt, sai chính tả, kèm số hiệp (sets), số rep, hoặc số giây.
   - HOẶC người dùng nhập yêu cầu/mô tả ngữ cảnh tạo buổi tập Calisthenics / bài tập tự trọng lượng (bodyweight training), rèn luyện sức bền (endurance), kỹ năng (skill: Handstand, Muscle up, L-sit, Front lever...), tim mạch đốt mỡ (cardio/HIIT), EMOM.
   - Xử lý: Đặt "isValid": true, "rejectionReason": null, và trích xuất hoặc thiết kế danh sách các bài tập Calisthenics phù hợp nhất.

2. NGỮ CẢNH KHÔNG HỢP LỆ (isValid: false):
   - Người dùng dán hoặc nhập thông tin ngoài việc KHÔNG LIÊN QUAN đến cấu trúc tạo bài tập trong Calisthenics hoặc thể thao thể hình.
   - Ví dụ KHÔNG HỢP LỆ:
     + Công thức nấu ăn, thực đơn món ăn, nguyên liệu ẩm thực (ví dụ: nấu phở, làm bánh, ướp thịt...).
     + Đoạn mã lập trình (code), thuật toán, giải bài tập tin học hoặc toán học.
     + Tin tức thời sự, kinh tế, thị trường, chứng khoán, chính trị, dự báo thời tiết.
     + Đoạn văn học, lời bài hát, thơ ca, trò chuyện giao tiếp thông thường phiếm ("Hôm nay bạn khỏe không", "Thời tiết hôm nay đẹp thế").
     + Danh sách mua sắm đồ đạc, đồ gia dụng, linh kiện máy móc, sửa xe.
     + Chuỗi ký tự ngẫu nhiên vô nghĩa, spam (ví dụ: "asdasdasd", "123123").
   - Xử lý khi KHÔNG HỢP LỆ:
     + TUYỆT ĐỐI KHÔNG TẠO BÀI TẬP TỰ ĐỘNG cho các ngữ cảnh này.
     + Đặt "isValid": false.
     + "rejectionReason": Nêu rõ lý do cụ thể bằng tiếng Việt lịch sự, thân thiện và hướng dẫn người dùng cung cấp đúng nội dung bài tập Calisthenics (ví dụ: "Nội dung bạn cung cấp nói về công thức nấu ăn, không liên quan đến cấu trúc bài tập Calisthenics. Vui lòng nhập danh sách động tác (như Hít đất, Xà đơn, Plank, Squat...) hoặc mô tả buổi tập Calisthenics mong muốn.").
     + "exercises": Bắt buộc trả về mảng rỗng [] (không tự ý bịa ra động tác).
     + "name": Để chuỗi rỗng "".

CẤU TRÚC JSON BẮT BUỘC TRẢ VỀ:
{
  "isValid": true, // hoặc false nếu nội dung không liên quan đến Calisthenics
  "rejectionReason": "Lý do từ chối cụ thể nếu isValid = false, hoặc null nếu isValid = true",
  "name": "Tên buổi tập ngắn gọn, viết hoa chữ cái đầu (ví dụ: Cardio Day, Ngực & Tay sau Calisthenics, Ab Workout...)",
  "category": "cardio | endurance | skill | emom",
  "description": "Tóm tắt ngắn gọn buổi tập (nếu có)",
  "targetRounds": 4, // Số hiệp/vòng (rounds/sets). Mặc định 1 nếu không nói rõ.
  "prepareSeconds": 10, // Thời gian chuẩn bị trước buổi tập (mặc định 10 giây).
  "defaultRestSeconds": 60, // Thời gian nghỉ giữa các hiệp (mặc định 60 giây).
  "timeCapSeconds": 0, // Giới hạn thời gian tổng (giây), mặc định 0 nếu không giới hạn.
  "exercises": [
    {
      "name": "Tên động tác Calisthenics chuẩn (sửa lỗi chính tả nếu có)",
      "defaultReps": 15, // Số lần lặp. Nếu là bài giữ tĩnh hoặc tính bằng giây thì defaultReps = 0.
      "holdSeconds": 0, // Số giây giữ tĩnh (ví dụ Plank 45s -> holdSeconds = 45, defaultReps = 0). Nếu bài tập tính rep thì holdSeconds = 0.
      "notes": "Ghi chú thêm nếu có (ví dụ: '30 giây mỗi bên', '10-15 reps') hoặc null"
    }
  ]
}

Quy tắc phân loại thể loại (category):
- "cardio": Bài tập HIIT, đốt mỡ, nhảy, nâng cao đùi, jumping jack, burpee, mountain climber, cardio day.
- "emom": Nếu văn bản ghi EMOM hoặc mỗi phút 1 bài.
- "skill": Các kỹ năng nâng cao như Handstand, Muscle Up, Planche, Front Lever, L-Sit.
- "endurance": Sức bền, các bài reps cơ bản Calisthenics (Push up, Pull up, Dip, Squat, bụng thông thường).

Quy tắc phân biệt Reps vs Hold:
- Nếu ghi "15 reps", "15 cái", "15 lần" -> defaultReps = 15, holdSeconds = 0.
- Nếu ghi "45 giây", "30s", "1 phút" -> holdSeconds = số giây tương ứng, defaultReps = 0.
- Các bài giữ tĩnh (Static Hold như Plank, Hollow Body Hold, Side Plank, Giữ nâng chân, L-sit, Wall Sit...): nếu không ghi rõ reps, ưu tiên holdSeconds và defaultReps = 0.
- Nếu có ghi khoảng (ví dụ: "10-15 reps") -> lấy mốc tối đa (defaultReps = 15) và lưu "10-15 reps" vào notes.
- Luôn trả về định dạng JSON thuần túy (Valid JSON). Không thêm bất kỳ text nào ngoài JSON.
''';

    final prompt =
        '''
Đánh giá ngữ cảnh và phân tích hoặc tạo bài tập từ nội dung sau thành JSON:

"""
$trimmedText
"""
''';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'systemInstruction': {
        'parts': [
          {'text': systemInstruction},
        ],
      },
      'generationConfig': {
        'response_mime_type': 'application/json',
        'temperature': 0.2,
      },
    };

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        final errorJson = _tryDecodeJson(response.body);
        final errorMessage =
            errorJson?['error']?['message'] ??
            'Lỗi gọi Gemini API (Mã lỗi: ${response.statusCode})';
        throw Exception(errorMessage);
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = responseBody['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini không trả về kết quả nào.');
      }

      final textContent =
          candidates[0]['content']?['parts']?[0]?['text'] as String?;
      if (textContent == null || textContent.trim().isEmpty) {
        throw Exception('Nội dung phản hồi từ Gemini rỗng.');
      }

      // Làm sạch JSON nếu có markdown formatting code blocks
      final cleanedJsonString = _sanitizeJsonString(textContent);
      final parsedJson = jsonDecode(cleanedJsonString) as Map<String, dynamic>;
      final parsedWorkout = AiParsedWorkout.fromJson(parsedJson);

      if (!parsedWorkout.isValid) {
        final reason = parsedWorkout.rejectionReason?.trim().isNotEmpty == true
            ? parsedWorkout.rejectionReason!.trim()
            : 'Nội dung bạn cung cấp không liên quan đến cấu trúc tạo bài tập Calisthenics. Vui lòng dán danh sách bài tập hoặc mô tả giáo án Calisthenics hợp lệ.';
        throw InvalidWorkoutContextException(reason);
      }

      if (parsedWorkout.exercises.isEmpty) {
        throw const InvalidWorkoutContextException(
          'Không tìm thấy động tác Calisthenics nào trong nội dung đã cung cấp. Vui lòng kiểm tra lại cấu trúc bài tập.',
        );
      }

      return parsedWorkout;
    } on FormatException catch (e) {
      throw Exception(
        'Không thể chuyển đổi kết quả AI thành JSON hợp lệ: ${e.message}',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi không xác định khi kết nối với Gemini: $e');
    }
  }

  String _sanitizeJsonString(String raw) {
    var text = raw.trim();
    if (text.startsWith('```json')) {
      text = text.substring(7);
    } else if (text.startsWith('```')) {
      text = text.substring(3);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3);
    }
    return text.trim();
  }

  Map<String, dynamic>? _tryDecodeJson(String text) {
    try {
      return jsonDecode(text) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
