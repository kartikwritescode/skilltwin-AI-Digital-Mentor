import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/journey_repository.dart';
import '../../data/repositories/journey_repository_provider.dart';
import '../../../../core/models/journey_node.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class JourneyState {
  final List<JourneyNode> nodes;
  final bool isLoading;
  final String? error;

  JourneyState({
    this.nodes = const [],
    this.isLoading = false,
    this.error,
  });

  JourneyState copyWith({
    List<JourneyNode>? nodes,
    bool? isLoading,
    String? error,
  }) {
    return JourneyState(
      nodes: nodes ?? this.nodes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final journeyProvider = StateNotifierProvider<JourneyNotifier, JourneyState>((ref) {
  final repository = ref.watch(journeyRepositoryProvider);
  return JourneyNotifier(repository);
});

class JourneyNotifier extends StateNotifier<JourneyState> {
  final JourneyRepository _repository;

  JourneyNotifier(this._repository) : super(JourneyState()) {
    loadJourney();
  }

  Future<void> loadJourney() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // In a real app, we'd get the goal ID from an active goal provider
      final nodes = await _repository.getJourneyNodes('active-goal-id');
      state = state.copyWith(nodes: nodes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  double get overallProgress {
    if (state.nodes.isEmpty) return 0.0;
    final completed = state.nodes.where((n) => n.status == NodeStatus.completed).length;
    return completed / state.nodes.length;
  }
}
