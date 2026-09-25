import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_provider.dart';
import '../../data/repositories/youtube_repository.dart';

final youtubeRepositoryProvider = Provider<YouTubeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return YouTubeRepository(apiClient);
});

final youtubePlaylistDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, playlistId) async {
  final repo = ref.watch(youtubeRepositoryProvider);
  return await repo.getPlaylist(playlistId);
});
