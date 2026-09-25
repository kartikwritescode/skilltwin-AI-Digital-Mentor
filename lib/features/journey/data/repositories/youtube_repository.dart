import '../../../../core/networking/api_client.dart';

class YouTubeRepository {
  final ApiClient _apiClient;

  YouTubeRepository(this._apiClient);

  Future<Map<String, dynamic>> importPlaylist({
    required String url,
    int dailyMinutes = 30,
    String targetLevel = 'Intermediate',
    DateTime? deadline,
    List<String>? currentKnowledge,
    String pace = 'normal',
    String revisionFrequency = 'every_few_days',
    bool strictMode = true,
  }) async {
    final response = await _apiClient.post(
      '/youtube/playlists/import',
      data: {
        'url': url,
        'daily_minutes': dailyMinutes,
        'target_level': targetLevel,
        if (deadline != null)
          'deadline': deadline.toIso8601String().split('T').first,
        if (currentKnowledge != null && currentKnowledge.isNotEmpty)
          'current_knowledge': currentKnowledge,
        'pace': pace,
        'revision_frequency': revisionFrequency,
        'strict_mode': strictMode,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPlaylist(String playlistId) async {
    final response = await _apiClient.get('/youtube/playlists/$playlistId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateVideoProgress({
    required String videoId,
    required String status,
    double watchProgress = 0.0,
    String? notes,
    double? rating,
  }) async {
    final response = await _apiClient.patch(
      '/youtube/videos/$videoId/progress',
      data: {
        'status': status,
        'watch_progress': watchProgress,
        if (notes != null) 'notes': notes,
        if (rating != null) 'user_rating': rating,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshPlaylist(String playlistId) async {
    final response = await _apiClient.post('/youtube/playlists/$playlistId/refresh');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recalculateSchedule({
    required String playlistId,
    required int dailyMinutes,
    String pace = 'normal',
    String revisionFrequency = 'every_few_days',
  }) async {
    final response = await _apiClient.post(
      '/youtube/playlists/$playlistId/schedule',
      data: {
        'daily_minutes': dailyMinutes,
        'pace': pace,
        'revision_frequency': revisionFrequency,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
