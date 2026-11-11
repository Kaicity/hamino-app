import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service_interface.dart';

/// Dịch vụ hỗ trợ giọng nói trợ lý ảo thông minh (Text-to-Speech)
class TtsService implements ITtsService {
  final FlutterTts _tts;

  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'vi-VN';
  double _currentSpeechRate = 0.52;
  double _currentPitch = 1.0;
  double _currentVolume = 1.0;
  bool isTtsEnabled = true;

  bool get isSpeaking => _isSpeaking;
  String get currentLanguage => _currentLanguage;
  double get currentSpeechRate => _currentSpeechRate;

  TtsService({FlutterTts? flutterTts}) : _tts = flutterTts ?? FlutterTts();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Đăng ký các callback theo dõi trạng thái đọc
      _tts.setStartHandler(() {
        _isSpeaking = true;
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
      });

      _tts.setErrorHandler((dynamic message) {
        _isSpeaking = false;
        debugPrint('[TtsService] TTS error: $message');
      });

      // Cấu hình ngôn ngữ mặc định (ưu tiên Tiếng Việt vi-VN, fallback Tiếng Anh en-US)
      final hasVietnamese = await isLanguageAvailable('vi-VN');
      if (hasVietnamese) {
        _currentLanguage = 'vi-VN';
      } else {
        final hasEnglish = await isLanguageAvailable('en-US');
        _currentLanguage = hasEnglish ? 'en-US' : 'vi-VN';
      }

      await _tts.setLanguage(_currentLanguage);
      await _tts.setSpeechRate(_currentSpeechRate);
      await _tts.setPitch(_currentPitch);
      await _tts.setVolume(_currentVolume);

      _isInitialized = true;
      debugPrint('[TtsService] Initialized with language: $_currentLanguage, rate: $_currentSpeechRate');
    } catch (e) {
      debugPrint('[TtsService] Error initializing TTS: $e');
      _isInitialized = true;
    }
  }

  @override
  Future<bool> isLanguageAvailable(String languageCode) async {
    try {
      final res = await _tts.isLanguageAvailable(languageCode);
      if (res is bool) return res;
      if (res is num) return res == 1;
      if (res is String) return res.toLowerCase() == 'true';
      return false;
    } catch (e) {
      debugPrint('[TtsService] isLanguageAvailable error: $e');
      return false;
    }
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    try {
      await _tts.setLanguage(languageCode);
    } catch (e) {
      debugPrint('[TtsService] Error setting language $languageCode: $e');
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _currentSpeechRate = rate;
    try {
      await _tts.setSpeechRate(rate);
    } catch (e) {
      debugPrint('[TtsService] Error setting speech rate $rate: $e');
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    _currentPitch = pitch;
    try {
      await _tts.setPitch(pitch);
    } catch (e) {
      debugPrint('[TtsService] Error setting pitch $pitch: $e');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    _currentVolume = volume;
    try {
      await _tts.setVolume(volume);
    } catch (e) {
      debugPrint('[TtsService] Error setting volume $volume: $e');
    }
  }

  @override
  Future<void> speak(String text, {bool awaitCompletion = false}) async {
    final cleanText = text.trim();
    if (!isTtsEnabled || cleanText.isEmpty) return;

    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (awaitCompletion) {
        await _tts.awaitSpeakCompletion(true);
      }

      _isSpeaking = true;
      await _tts.speak(cleanText);
    } catch (e) {
      _isSpeaking = false;
      debugPrint('[TtsService] Error speaking: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[TtsService] Error stopping TTS: $e');
    } finally {
      _isSpeaking = false;
    }
  }
}

