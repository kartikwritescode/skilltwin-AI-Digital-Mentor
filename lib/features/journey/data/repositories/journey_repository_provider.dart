import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import '../../domain/repositories/journey_repository.dart';
import 'journey_repository_impl.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JourneyRepositoryImpl(apiClient);
});
