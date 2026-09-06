import '../../domain/repositories/mentor_repository.dart';
import '../../../../core/models/mentor_message.dart';

class MockMentorRepository implements MentorRepository {
  @override
  Future<List<MentorMessage>> getDailyMentorBriefing() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      MentorMessage(
        id: '1',
        text: "Don't start Transformers yet.\n\nYour neural-network fundamentals need one more pass.\n\nI'd fix backpropagation first.",
        sender: MessageSender.mentor,
        intent: MentorIntent.remediate,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ctaText: 'Start 15-minute session',
        actionType: MentorAction.remediate,
        actionData: {'concept_id': 'backprop_001'},
        whyContext: 'Recent retrieval accuracy on the Chain Rule is below 60%, which is a hard prerequisite for understanding Transformer gradients.',
        conceptId: 'backpropagation',
        conceptTitle: 'Backpropagation',
      ),
    ];
  }

  @override
  Future<MentorMessage> sendMessage(String text) async {
    await Future.delayed(const Duration(seconds: 1));
    if (text.toLowerCase().contains('why')) {
      return MentorMessage(
        id: DateTime.now().toString(),
        text: "Backpropagation is the engine of almost all modern AI. If you don't intuitively understand how the error signal flows backward through the chain rule, you'll struggle with the vanishing gradient problems common in deep architectures.",
        sender: MessageSender.mentor,
        intent: MentorIntent.inform,
        timestamp: DateTime.now(),
      );
    }
    
    return MentorMessage(
      id: DateTime.now().toString(),
      text: "I've updated your plan. We'll focus on the specific derivatives in the Chain Rule for 10 minutes.",
      sender: MessageSender.mentor,
      intent: MentorIntent.clarify,
      timestamp: DateTime.now(),
      ctaText: 'Begin Practice',
      actionType: MentorAction.practice,
      actionData: {'sub_concept': 'derivatives'},
    );
  }

  @override
  Future<String> getWhyExplanation(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "Based on your last three sessions, you correctly applied the Power Rule but failed twice on the Chain Rule when nested functions were involved. Transformers rely heavily on nested attention mechanisms.";
  }
}
