/// Giao diện dịch vụ trợ lý giọng đọc Text-to-Speech
abstract class ITtsService {
  Future<void> initialize();
  Future<void> speak(String text, {bool awaitCompletion = false});
  Future<void> stop();
  Future<void> setLanguage(String languageCode);
  Future<void> setSpeechRate(double rate);
  Future<void> setVolume(double volume);
  Future<void> setPitch(double pitch);
  Future<bool> isLanguageAvailable(String languageCode);
}

