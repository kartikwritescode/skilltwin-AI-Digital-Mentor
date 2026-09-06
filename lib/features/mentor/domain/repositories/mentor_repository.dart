import '../../../../core/models/mentor_message.dart';

abstract class MentorRepository {
  /// Fetches the initial mentor state for the day or session start
  Future<List<MentorMessage>> getDailyMentorBriefing();
  
  /// Sends a user message and gets structured mentor response
  Future<MentorMessage> sendMessage(String text);
  
  /// Gets a specific explanation for a recommendation
  Future<String> getWhyExplanation(String messageId);
}
