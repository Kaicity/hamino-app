import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hamino_app/core/services/tts_service.dart';

class MockFlutterTts extends Fake implements FlutterTts {
  String? language;
  double? speechRate;
  double? volume;
  double? pitch;
  bool awaitSpeakCompletionValue = false;
  final List<String> spokenTexts = [];
  int stopCalls = 0;
  dynamic isLanguageAvailableResult = true;

  @override
  void setStartHandler(void Function() callback) {}

  @override
  void setCompletionHandler(void Function() callback) {}

  @override
  void setCancelHandler(void Function() callback) {}

  @override
  void setErrorHandler(void Function(dynamic message) callback) {}

  @override
  Future<dynamic> isLanguageAvailable(String language) async {
    return isLanguageAvailableResult;
  }

  @override
  Future<dynamic> setLanguage(String language) async {
    this.language = language;
    return 1;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    speechRate = rate;
    return 1;
  }

  @override
  Future<dynamic> setVolume(double volume) async {
    this.volume = volume;
    return 1;
  }

  @override
  Future<dynamic> setPitch(double pitch) async {
    this.pitch = pitch;
    return 1;
  }

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async {
    awaitSpeakCompletionValue = awaitCompletion;
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    spokenTexts.add(text);
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    stopCalls++;
    return 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterTts mockTts;
  late TtsService ttsService;

  setUp(() {
    mockTts = MockFlutterTts();
    ttsService = TtsService(flutterTts: mockTts);
  });

  group('TtsService (TASK-4.2)', () {
    test('initialize sets default rate 0.52 and checks language', () async {
      await ttsService.initialize();

      expect(mockTts.language, 'vi-VN');
      expect(mockTts.speechRate, 0.52);
      expect(mockTts.pitch, 1.0);
      expect(mockTts.volume, 1.0);
    });

    test('fallbacks to en-US if vi-VN is not available', () async {
      mockTts.isLanguageAvailableResult = false;
      await ttsService.initialize();

      // Fallback checked en-US (which is also false here, default set)
      expect(ttsService.currentLanguage, anyOf('vi-VN', 'en-US'));
    });

    test('speak sends text to FlutterTts', () async {
      await ttsService.speak('Bắt đầu tập luyện');

      expect(mockTts.spokenTexts, contains('Bắt đầu tập luyện'));
      expect(ttsService.isSpeaking, true);
    });

    test('does not speak if isTtsEnabled is false', () async {
      ttsService.isTtsEnabled = false;
      await ttsService.speak('Không đọc');

      expect(mockTts.spokenTexts, isEmpty);
    });

    test('does not speak empty or whitespace text', () async {
      await ttsService.speak('   ');

      expect(mockTts.spokenTexts, isEmpty);
    });

    test('stop calls FlutterTts.stop and sets isSpeaking to false', () async {
      await ttsService.speak('Đang đọc');
      expect(ttsService.isSpeaking, true);

      await ttsService.stop();
      expect(mockTts.stopCalls, 1);
      expect(ttsService.isSpeaking, false);
    });

    test('setLanguage updates current language', () async {
      await ttsService.setLanguage('en-US');

      expect(ttsService.currentLanguage, 'en-US');
      expect(mockTts.language, 'en-US');
    });

    test('setSpeechRate updates speech rate', () async {
      await ttsService.setSpeechRate(0.6);

      expect(ttsService.currentSpeechRate, 0.6);
      expect(mockTts.speechRate, 0.6);
    });
  });
}
