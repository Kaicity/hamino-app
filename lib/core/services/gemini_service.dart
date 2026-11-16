import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // Model khuyến nghị: gemini-1.5-flash (nhanh, rẻ, phản hồi chuẩn xác cho tác vụ trích xuất cấu trúc)
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

    if (rawText.trim().isEmpty) {
      throw Exception('Vui lòng nhập danh sách bài tập thô để AI phân tích.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_defaultModel:generateContent?key=$effectiveApiKey',
    );

    final systemInstruction = '''
Bạn là chuyên gia huấn luyện viên Calisthenics và thể hình của ứng dụng Hamino.
Nhiệm vụ của bạn là đọc và phân tích đoạn văn bản thô do người dùng cung cấp chứa danh sách bài tập (có thể viết tắt, sai chính tả, tiếng Việt hoặc tiếng Anh, có số hiệp, số rep, số giây, hoặc ghi chú) và chuyển đổi thành một đối tượng JSON hợp lệ theo đúng cấu trúc sau:

{
  "name": "Tên bài tập ngắn gọn, viết hoa chữ cái đầu (ví dụ: Cardio Day, Ab Workout, Full Body, v.v.)",
  "category": "cardio | endurance | skill | emom",
  "description": "Tóm tắt ngắn gọn buổi tập (nếu có)",
  "targetRounds": 4, // Số hiệp/vòng (rounds/sets). Mặc định 1 nếu văn bản không nhắc đến.
  "prepareSeconds": 10, // Thời gian chuẩn bị trước buổi tập (mặc định 10 giây).
  "defaultRestSeconds": 60, // Thời gian nghỉ giữa các hiệp (mặc định 60 giây, trừ khi người dùng ghi rõ khác).
  "timeCapSeconds": 0, // Giới hạn thời gian tổng (giây), mặc định 0 nếu không giới hạn.
  "exercises": [
    {
      "name": "Tên động tác chuẩn (sửa lỗi chính tả nếu có, ví dụ Bicycle Crunc -> Bicycle Crunch, Nâng chân -> Nâng chân)",
      "defaultReps": 15, // Số lần lặp. Nếu là bài giữ tĩnh hoặc tính bằng giây thì defaultReps = 0.
      "holdSeconds": 0, // Số giây giữ tĩnh (ví dụ Plank 45s -> holdSeconds = 45, defaultReps = 0). Nếu bài tập tính rep thì holdSeconds = 0.
      "notes": "Ghi chú thêm nếu có (ví dụ: '30 giây mỗi bên', '10-15 reps', 'chậm kiểm soát') hoặc null"
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
- Các bài giữ tĩnh (Static Hold như Plank, Hollow Body Hold, Side Plank, Giữ nâng chân, L-sit, Wall Sit...): nếu người dùng chỉ ghi số (ví dụ "Hollow Body Hold - 20") mà không ghi rõ reps, hãy ưu tiên holdSeconds = 20 và defaultReps = 0.
- Nếu có ghi khoảng (ví dụ: "10-15 reps") -> lấy mốc tối đa (defaultReps = 15) và lưu "10-15 reps" vào notes.
- Nếu có ghi "mỗi bên" -> lưu vào notes (ví dụ notes: "30 giây mỗi bên").
- Luôn trả về định dạng JSON thuần túy (Valid JSON). Không thêm bất kỳ text nào ngoài JSON.
''';

    final prompt =
        '''
Phân tích danh sách bài tập sau đây thành JSON:

"""
$rawText
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

      return AiParsedWorkout.fromJson(parsedJson);
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
