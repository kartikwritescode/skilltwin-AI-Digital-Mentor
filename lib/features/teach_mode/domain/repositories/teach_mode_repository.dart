import 'dart:io';

abstract class TeachModeRepository {
  Future<void> startVoiceSession();
  Future<void> stopVoiceSession();
  Future<Map<String, dynamic>> getUnderstandingReport();
  Future<String?> transcribeAudio(File audioFile, {String? conceptId});
  Future<Map<String, dynamic>> evaluateExplanation(String conceptId, String explanationText);
}
