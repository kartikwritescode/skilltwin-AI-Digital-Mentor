import '../../../../core/networking/api_client.dart';
import '../../../../core/models/mentor_message.dart';
import '../../domain/repositories/mentor_repository.dart';
import 'mock_mentor_repository.dart';

class MentorRepositoryImpl implements MentorRepository {
  final ApiClient _apiClient;
  final MockMentorRepository _fallback = MockMentorRepository();

  MentorRepositoryImpl(this._apiClient);

  @override
  Future<List<MentorMessage>> getDailyMentorBriefing() async {
    try {
      final response = await _apiClient.get('/mentor/today');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => MentorMessage.fromJson(e))
            .where((m) => m.text.trim().isNotEmpty)
            .toList();
      } else if (response.data is Map<String, dynamic>) {
        final msg = MentorMessage.fromJson(response.data);
        return msg.text.trim().isNotEmpty ? [msg] : [];
      }
      return _fallback.getDailyMentorBriefing();
    } catch (_) {
      return _fallback.getDailyMentorBriefing();
    }
  }

  @override
  Future<MentorMessage> sendMessage(String text, {Map<String, dynamic>? context}) async {
    try {
      final response = await _apiClient.post(
        '/mentor/message',
        data: {
          'message': text,
          'text': text,
          if (context != null) 'context': context,
        },
      );
      if (response.data is Map<String, dynamic>) {
        // Backend returns {"reply": String, ...} or standard MentorMessage json
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('reply') && !data.containsKey('content')) {
          return MentorMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: data['reply'].toString(),
            role: 'assistant',
            sender: MessageSender.mentor,
            timestamp: DateTime.now(),
            ctaText: data['action_suggested']?.toString(),
          );
        }
        return MentorMessage.fromJson(data);
      }
      return _fallback.sendMessage(text, context: context);
    } catch (_) {
      return _fallback.sendMessage(text, context: context);
    }
  }

  @override
  Future<String> getWhyExplanation(String messageId) async {
    try {
      final response = await _apiClient.get('/mentor/why/$messageId');
      return response.data['explanation'] ?? response.data['reply'] ?? '';
    } catch (_) {
      return _fallback.getWhyExplanation(messageId);
    }
  }
}
