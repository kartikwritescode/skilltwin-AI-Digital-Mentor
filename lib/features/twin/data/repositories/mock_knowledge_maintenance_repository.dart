import '../../domain/repositories/knowledge_maintenance_repository.dart';
import '../../../../core/models/knowledge_maintenance_item.dart';

class MockKnowledgeMaintenanceRepository implements KnowledgeMaintenanceRepository {
  @override
  Future<List<KnowledgeMaintenanceItem>> getMaintenancePlan() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      KnowledgeMaintenanceItem(
        id: 'km1',
        conceptId: 'linear_regression',
        conceptTitle: 'Linear Regression',
        status: MaintenanceStatus.keep,
        reason: "You've demonstrated strong understanding.",
        mentorRecommendation: "Your mental model is stable. No action required for now.",
      ),
      KnowledgeMaintenanceItem(
        id: 'km2',
        conceptId: 'bias_variance',
        conceptTitle: 'Bias-Variance Tradeoff',
        status: MaintenanceStatus.fix,
        reason: "You repeatedly confuse high variance with underfitting.",
        mentorRecommendation: "I recommend a targeted 10-minute remediation to clarify why high variance is not underfitting.",
        ctaAction: 'remediate_bias_variance',
        ctaLabel: 'FIX MISCONCEPTION',
      ),
      KnowledgeMaintenanceItem(
        id: 'km3',
        conceptId: 'probability',
        conceptTitle: 'Probability',
        status: MaintenanceStatus.revise,
        reason: "Your delayed retrieval performance is declining.",
        mentorRecommendation: "Let's do a 5-minute retrieval session to protect your mastery score from further decay.",
        ctaAction: 'revise_probability',
        ctaLabel: 'START REVISION',
      ),
      KnowledgeMaintenanceItem(
        id: 'km4',
        conceptId: 'model_evaluation',
        conceptTitle: 'Model Evaluation',
        status: MaintenanceStatus.learnNext,
        reason: "This is the next prerequisite in your journey.",
        mentorRecommendation: "You've mastered the prerequisites. I have synthesized a set of personalized notes for you to start this concept.",
        ctaAction: 'note_1', // Custom prefix to handle in UI
        ctaLabel: 'READ PERSONALIZED NOTES',
      ),
      KnowledgeMaintenanceItem(
        id: 'km5',
        conceptId: 'manual_feature_eng',
        conceptTitle: 'Manual Feature Engineering',
        status: MaintenanceStatus.deprioritize,
        reason: "Your goal emphasizes automated pipelines (AutoML).",
        mentorRecommendation: "I've moved this to 'Reference' to focus on high-leverage skills first.",
      ),
    ];
  }

  @override
  Future<void> updateMaintenanceStatus(String itemId, MaintenanceStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
