import '../../domain/repositories/teach_mode_repository.dart';

class MockTeachModeRepository implements TeachModeRepository {
  @override
  Future<void> startVoiceSession() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> stopVoiceSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<Map<String, dynamic>> getUnderstandingReport() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return {
      'conceptual_accuracy': 0.85,
      'completeness': 0.70,
      'reasoning': 0.90,
      'confidence': 0.65,
      'transfer': 0.75,
      'misconceptions': [
        'Confused bias adjustment with weight gradients.',
        'Assumption that learning rate is constant across all layers.'
      ],
      'feedback': 'Your explanation of the chain rule logic was perfect. However, you missed how the loss function actually initiates the backward pass.',
      'recommendation': 'I recommend a 5-minute targeted session on "Loss Gradients" to bridge this gap.',
      'fix_action_id': 'remediate_loss_gradients',
    };
  }
}
