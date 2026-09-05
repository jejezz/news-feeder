import 'package:google_mlkit_translation/google_mlkit_translation.dart';

typedef Translator = Future<String> Function(String text);

class TranslationService {
  TranslationService({
    this.sourceLanguage = TranslateLanguage.english,
    this.targetLanguage = TranslateLanguage.korean,
  });

  final TranslateLanguage sourceLanguage;
  final TranslateLanguage targetLanguage;

  OnDeviceTranslator? _translator;
  Future<void>? _modelsReady;

  Future<String> translate(String text) async {
    if (text.trim().isEmpty) return text;
    await (_modelsReady ??= _downloadModelsIfNeeded());
    _translator ??= OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
    return _translator!.translateText(text);
  }

  Future<void> _downloadModelsIfNeeded() async {
    final manager = OnDeviceTranslatorModelManager();
    for (final language in {sourceLanguage, targetLanguage}) {
      final isDownloaded = await manager.isModelDownloaded(language.bcpCode);
      if (!isDownloaded) {
        // Model download is small (a few MB per language); not worth
        // forcing wifi-only for a one-time background fetch.
        await manager.downloadModel(language.bcpCode, isWifiRequired: false);
      }
    }
  }

  void close() {
    _translator?.close();
  }
}
