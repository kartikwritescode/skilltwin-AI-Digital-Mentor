import '../../domain/repositories/twin_repository.dart';
import '../../../../core/models/learner_concept.dart';
import '../../../../core/models/evidence.dart';
import '../../../../core/models/twin_dashboard.dart';

class MockTwinRepository implements TwinRepository {
  @override
  Future<TwinDashboardData> getTwinDashboard() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const TwinDashboardData(
      userId: 'mock-user',
      hasSufficientData: true,
      overallMastery: 0.68,
      learningLevel: 'Intermediate',
      strongestAreas: [
        AreaMasteryItem(name: 'Python', masteryScore: 0.95, status: 'MASTERED'),
        AreaMasteryItem(name: 'Data Wrangling', masteryScore: 0.85, status: 'MASTERED'),
      ],
      weakestAreas: [
        AreaMasteryItem(name: 'Probability', masteryScore: 0.45, status: 'NEEDS_REVISION'),
      ],
      conceptsAtRisk: ['Conditional Probability'],
      consistencyStreak: 5,
      learningVelocity: 1.2,
      knowledgeCoverage: 0.4,
      verifiedEvidenceCount: 15,
      insights: [
        "Your understanding of core algorithms is solid.",
        "Focus on spaced retrieval for probability before proceeding.",
      ],
    );
  }

  @override
  Future<List<LearnerConcept>> getLearnerState() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      LearnerConcept(
        conceptId: 'python_basics',
        mastery: 0.95,
        confidence: 0.9,
        retention: 0.88,
        risk: 0.05,
        status: ConceptStatus.mastered,
        evidenceCount: 12,
      ),
      LearnerConcept(
        conceptId: 'probability',
        mastery: 0.45,
        confidence: 0.3,
        retention: 0.6,
        risk: 0.7,
        status: ConceptStatus.needsReview,
        evidenceCount: 3,
        misconceptionTags: ['Conditional Probability', 'Bayes Prior'],
      ),
      LearnerConcept(
        conceptId: 'recursion',
        mastery: 0.75,
        confidence: 0.8,
        retention: 0.4,
        risk: 0.65,
        status: ConceptStatus.learning,
        evidenceCount: 8,
      ),
      LearnerConcept(
        conceptId: 'backpropagation',
        mastery: 0.3,
        confidence: 0.2,
        retention: 0.5,
        risk: 0.8,
        status: ConceptStatus.uncertain,
        evidenceCount: 1,
      ),
    ];
  }

  @override
  Future<List<Evidence>> getEvidenceHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      Evidence(
        id: 'e1',
        conceptId: 'python_basics',
        description: 'Successfully implemented a decorator for logging.',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Evidence(
        id: 'e2',
        conceptId: 'recursion',
        description: 'Explained the base case and recursive step in Fibonacci.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<LearnerConcept> getConceptById(String conceptId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final concepts = await getLearnerState();
    return concepts.firstWhere(
      (c) => c.conceptId == conceptId,
      orElse: () => LearnerConcept(
        conceptId: conceptId,
        mastery: 0,
        confidence: 0,
        retention: 0,
        risk: 0,
        status: ConceptStatus.notLearned,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> getTwinOverview() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'overall_understanding': 0.68,
      'strong_areas': ['Python', 'Data Wrangling'],
      'developing_areas': ['Recursion', 'Linear Algebra'],
      'needs_attention': ['Probability'],
      'insights': [
        "You're strong in Python.",
        "Probability is currently holding back your ML progress.",
        "Your understanding of recursion is good immediately after learning, but weaker after delayed retrieval."
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getGraphTopology() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'nodes': [
        {'id': 'python_basics', 'name': 'Python Basics', 'domain': 'programming', 'tier': 1, 'mastery_score': 95.0, 'status': 'MASTERED'},
        {'id': 'linear_algebra', 'name': 'Linear Algebra', 'domain': 'math', 'tier': 1, 'mastery_score': 60.0, 'status': 'LEARNING'},
        {'id': 'probability', 'name': 'Probability & Bayes', 'domain': 'math', 'tier': 1, 'mastery_score': 45.0, 'status': 'NEEDS_REVIEW'},
        {'id': 'gradient_descent', 'name': 'Gradient Descent', 'domain': 'ml', 'tier': 2, 'mastery_score': 70.0, 'status': 'LEARNING'},
        {'id': 'backpropagation', 'name': 'Backpropagation', 'domain': 'ml', 'tier': 3, 'mastery_score': 30.0, 'status': 'UNCERTAIN'},
      ],
      'edges': [
        {'source': 'linear_algebra', 'target': 'gradient_descent', 'relationship': 'prerequisite'},
        {'source': 'gradient_descent', 'target': 'backpropagation', 'relationship': 'prerequisite'},
      ]
    };
  }
}
