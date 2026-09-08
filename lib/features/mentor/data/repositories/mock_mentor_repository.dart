import '../../domain/repositories/mentor_repository.dart';
import '../../../../core/models/mentor_message.dart';

class MockMentorRepository implements MentorRepository {
  @override
  Future<List<MentorMessage>> getDailyMentorBriefing() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      MentorMessage(
        id: '1',
        text: "Welcome back!\n\nLet's focus on your active milestone today.\n\nMastering foundational invariants first prevents compounding cognitive debt.",
        sender: MessageSender.mentor,
        intent: MentorIntent.inform,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ctaText: 'Start 15-minute session',
        actionType: MentorAction.practice,
        actionData: {'concept_id': 'active_milestone_001'},
        whyContext: 'Targeted daily deliberate practice strengthens retention and interrupts the forgetting curve.',
        conceptId: 'active_milestone',
        conceptTitle: 'Active Milestone Practice',
      ),
    ];
  }

  @override
  Future<MentorMessage> sendMessage(String text, {Map<String, dynamic>? context}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final topic = context?['current_topic'] ?? context?['target_topic'] ?? 'this concept';
    final lower = text.toLowerCase();
    if (lower.contains('why')) {
      return MentorMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "We prioritize **$topic** because cognitive evidence shows that skipping foundational invariants causes knowledge debt. Mastering this unlocks intuitive problem solving downstream.",
        sender: MessageSender.mentor,
        intent: MentorIntent.inform,
        timestamp: DateTime.now(),
      );
    }

    return MentorMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "I've structured a focused practice session around **$topic**. Let's break down the core properties first, then verify with test cases.",
      sender: MessageSender.mentor,
      intent: MentorIntent.clarify,
      timestamp: DateTime.now(),
      ctaText: 'Begin Practice',
      actionType: MentorAction.practice,
      actionData: {'sub_concept': topic},
    );
  }

  @override
  Future<String> getWhyExplanation(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return "Based on your active study trajectory, reinforcing core mechanisms early produces the highest compound knowledge velocity.";
  }
}
