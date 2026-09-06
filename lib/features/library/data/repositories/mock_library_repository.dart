import 'dart:io';
import '../../domain/repositories/library_repository.dart';
import '../../../../core/models/resource.dart';

class MockLibraryRepository implements LibraryRepository {
  final List<Resource> _mockResources = [
    Resource(
      id: '1',
      title: 'Neural Networks: A Visual Introduction',
      type: ResourceType.pdf,
      status: ResourceStatus.ready,
      mentorLabel: ResourceLabel.useNow,
      url: 'https://example.com/nn_intro.pdf',
      extractedConcepts: ['Neurons', 'Weights', 'Activation Functions', 'Forward Pass'],
      usedByJourneyNodes: ['Foundations', 'Neural Network Architectures'],
      synthesisMentorNote: 'I have shaped these notes to address your recurring confusion between weights and biases, and connected them directly to your "Deep Learning" goal.',
      synthesisInputs: ['Goal: AI Engineer', 'Weakness: Calculus Primitives', 'Stage: Foundations'],
      generatedNotes: """
# Personalized Notes: Neural Network Foundations

*Synthesized for your goal: Become an AI/ML Engineer*

### Why these notes are different
Your mentor has prioritized **Activation Functions** and **Weights** because your recent retrieval on 'Linear Algebra Primitives' was slightly below baseline. 

### 1. Neurons and Weights
Think of a weight as the 'importance' of a specific input. In your last session, you confused this with the bias term. 
- **Weights:** Control the slope of the signal.
- **Bias:** Controls when the neuron 'fires' (the threshold).

### 2. Activation Functions
Since you are currently in the **Foundations** stage of your journey, we focus on the intuition:
- **Sigmoid:** Good for probabilities (which you know well from your Python projects).
- **ReLU:** The standard for deep networks. We will use this in the next 'Neural Networks' node.

### 3. Connection to Your Goal
Mastering these primitives now will prevent 'Knowledge Debt' when we reach **Backpropagation** in Phase 2.
""",
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Resource(
      id: '2',
      title: 'Backpropagation Step-by-Step',
      type: ResourceType.link,
      status: ResourceStatus.ready,
      mentorLabel: ResourceLabel.keep,
      url: 'https://blog.skilltwin.ai/backprop',
      extractedConcepts: ['Partial Derivatives', 'Chain Rule', 'Gradient Descent'],
      usedByJourneyNodes: ['Backpropagation'],
      synthesisMentorNote: 'Focusing on the multidimensional Chain Rule which was a blocker in your last retrieval session.',
      synthesisInputs: ['Weakness: Chain Rule', 'Goal: Deep Learning', 'Action: Remediate'],
      generatedNotes: """
# Mentor Note: The Calculus of Learning

*Focus Area: Misconception Repair (Chain Rule)*

### Context
Your learner twin shows a recurring confusion between **Partial Derivatives** and total derivatives in nested functions. These notes emphasize the 'flow' of gradients.

### Key Logic
1. **The Chain Rule:** You successfully applied this in 1D, but struggle with multidimensional tensors.
2. **Gradient Descent:** Think of this as 'walking downhill' in the loss landscape.

### Next Action
After reading this, I recommend a **Prove** session to verify your mental model of the backward pass.
""",
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<Resource>> getResources({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (query == null || query.isEmpty) return _mockResources;
    return _mockResources
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<Resource> uploadPdf(File file, String title) async {
    await Future.delayed(const Duration(seconds: 1));
    final resource = Resource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: ResourceType.pdf,
      status: ResourceStatus.uploading,
      createdAt: DateTime.now(),
    );
    _mockResources.insert(0, resource);
    return resource;
  }

  @override
  Future<Resource> addLink(String url, String title) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final resource = Resource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: ResourceType.link,
      url: url,
      status: ResourceStatus.ready,
      createdAt: DateTime.now(),
    );
    _mockResources.insert(0, resource);
    return resource;
  }

  @override
  Future<Resource> createNote(String content, String title) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final resource = Resource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: ResourceType.note,
      content: content,
      status: ResourceStatus.ready,
      createdAt: DateTime.now(),
    );
    _mockResources.insert(0, resource);
    return resource;
  }

  @override
  Future<void> deleteResource(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockResources.removeWhere((r) => r.id == id);
  }

  @override
  Future<Resource> getResourceDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockResources.firstWhere((r) => r.id == id);
  }
}
