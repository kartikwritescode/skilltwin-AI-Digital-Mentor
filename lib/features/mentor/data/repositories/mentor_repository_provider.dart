import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import '../../domain/repositories/mentor_repository.dart';
import 'mentor_repository_impl.dart';

final mentorRepositoryProvider = Provider<MentorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MentorRepositoryImpl(apiClient);
});
