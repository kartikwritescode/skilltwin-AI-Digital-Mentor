import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/networking/api_client.dart';
import '../../domain/repositories/teach_mode_repository.dart';
import 'mock_teach_mode_repository.dart';

class TeachModeRepositoryImpl implements TeachModeRepository {
  final ApiClient _apiClient;
  final MockTeachModeRepository _fallback = MockTeachModeRepository();

  TeachModeRepositoryImpl(this._apiClient);

  @override
  Future<void> startVoiceSession() async {
    // Local device session or signaling
  }

  @override
  Future<void> stopVoiceSession() async {
    // Local device session or signaling
  }

  @override
  Future<Map<String, dynamic>> getUnderstandingReport() async {
    return _fallback.getUnderstandingReport();
  }

  @override
  Future<String?> transcribeAudio(File audioFile, {String? conceptId}) async {
    try {
      final mapData = <String, dynamic>{
        'file': await MultipartFile.fromFile(audioFile.path, filename: 'teach_audio.m4a'),
      };
      if (conceptId != null && conceptId.isNotEmpty) {
        mapData['concept_id'] = conceptId;
      }
      final formData = FormData.fromMap(mapData);
      final response = await _apiClient.post('/teach/transcribe', data: formData);
      return response.data['transcript'] ?? response.data['text'];
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> evaluateExplanation(String conceptId, String explanationText) async {
    try {
      final response = await _apiClient.post('/teach/evaluate', data: {
        'concept_id': conceptId,
        'explanation_text': explanationText,
      });
      return Map<String, dynamic>.from(response.data);
    } catch (_) {
      return _fallback.getUnderstandingReport();
    }
  }
}
