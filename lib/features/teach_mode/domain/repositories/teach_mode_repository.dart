abstract class TeachModeRepository {
  Future<void> startVoiceSession();
  Future<void> stopVoiceSession();
  Future<Map<String, dynamic>> getUnderstandingReport();
}
