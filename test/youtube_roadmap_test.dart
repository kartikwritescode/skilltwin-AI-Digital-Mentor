import 'package:flutter_test/flutter_test.dart';
import 'package:skilltwin/core/models/learning_path.dart';
import 'package:skilltwin/core/models/topic_detail.dart';

void main() {
  group('YouTube Roadmap Models & Metadata Tests', () {
    test('LearningPath parses YouTube curriculum metadata correctly', () {
      final json = {
        'id': 'path-yt-123',
        'goal_id': 'goal-yt-123',
        'title': 'NeetCode 150 - Data Structures & Algorithms',
        'description': 'Master DSA following the creator authoritative sequence',
        'target_level': 'intermediate',
        'progress': 0.25,
        'estimated_duration': '24h 30m',
        'sections': [
          {
            'id': 'sec-1',
            'title': 'Module 1: Arrays & Hashing',
            'order_index': 0,
            'description': 'Foundational array structures',
            'topics': [
              {
                'id': 'top-1',
                'title': 'Contains Duplicate',
                'order_index': 0,
                'difficulty': 'beginner',
                'status': 'completed',
                'mastery_score': 0.9,
                'metadata': {
                  'source_type': 'youtube_playlist',
                  'youtube_video_id': '3OamzN90kPg',
                  'youtube_url': 'https://www.youtube.com/watch?v=3OamzN90kPg',
                  'duration_seconds': 720,
                  'position': 0,
                  'thumbnail_url': 'https://i.ytimg.com/vi/3OamzN90kPg/hqdefault.jpg',
                  'channel_name': 'NeetCode',
                },
              },
              {
                'id': 'top-2',
                'title': 'Valid Anagram',
                'order_index': 1,
                'difficulty': 'beginner',
                'status': 'not_started',
                'mastery_score': 0.0,
                'metadata': {
                  'source_type': 'youtube_playlist',
                  'youtube_video_id': '9UtInBqnCgA',
                  'youtube_url': 'https://www.youtube.com/watch?v=9UtInBqnCgA',
                  'duration_seconds': 540,
                  'position': 1,
                  'channel_name': 'NeetCode',
                },
              }
            ],
          }
        ],
        'metadata': {
          'source_type': 'youtube_playlist',
          'youtube_playlist_id': 'PLot-Xpze53ldVwtstag2TL4HQhAnC8ATf',
          'channel_name': 'NeetCode',
          'strict_sequence': true,
          'total_videos': 2,
        },
      };

      final path = LearningPath.fromJson(json);

      expect(path.isYouTubeCurriculum, isTrue);
      expect(path.youtubePlaylistId, equals('PLot-Xpze53ldVwtstag2TL4HQhAnC8ATf'));
      expect(path.channelName, equals('NeetCode'));
      expect(path.isStrictMode, isTrue);
      expect(path.sections.length, equals(1));

      final topic1 = path.sections.first.topics[0];
      expect(topic1.isYouTubeVideo, isTrue);
      expect(topic1.youtubeVideoId, equals('3OamzN90kPg'));
      expect(topic1.youtubeUrl, equals('https://www.youtube.com/watch?v=3OamzN90kPg'));
      expect(topic1.durationSeconds, equals(720));
      expect(topic1.position, equals(0));
      expect(topic1.thumbnailUrl, equals('https://i.ytimg.com/vi/3OamzN90kPg/hqdefault.jpg'));

      final topic2 = path.sections.first.topics[1];
      expect(topic2.isYouTubeVideo, isTrue);
      expect(topic2.position, equals(1));
      expect(topic2.durationSeconds, equals(540));
    });

    test('TopicDetailData parses YouTube metadata and getters correctly', () {
      final json = {
        'id': 'top-1',
        'title': 'Contains Duplicate',
        'difficulty': 'beginner',
        'status': 'learning',
        'mastery_score': 0.75,
        'revision_count': 1,
        'description': 'Use hash set to detect duplicate items in linear time.',
        'learning_objectives': ['Understand set lookup', 'Time complexity O(N)'],
        'key_concepts': ['HashSet', 'Hash Table', 'Arrays'],
        'prerequisites': [],
        'metadata': {
          'source_type': 'youtube_playlist',
          'youtube_video_id': '3OamzN90kPg',
          'youtube_url': 'https://www.youtube.com/watch?v=3OamzN90kPg',
          'duration_seconds': 720,
          'position': 0,
          'thumbnail_url': 'https://i.ytimg.com/vi/3OamzN90kPg/hqdefault.jpg',
          'channel_name': 'NeetCode',
        },
      };

      final detail = TopicDetailData.fromJson(json);

      expect(detail.isYouTubeVideo, isTrue);
      expect(detail.youtubeVideoId, equals('3OamzN90kPg'));
      expect(detail.youtubeUrl, equals('https://www.youtube.com/watch?v=3OamzN90kPg'));
      expect(detail.durationSeconds, equals(720));
      expect(detail.position, equals(0));
      expect(detail.channelName, equals('NeetCode'));
      expect(detail.keyConcepts, contains('HashSet'));
    });

    test('Standard non-YouTube topic defaults cleanly without errors', () {
      final json = {
        'id': 'top-std',
        'title': 'Standard AI Topic',
        'difficulty': 'intermediate',
        'status': 'not_started',
        'mastery_score': 0.0,
        'revision_count': 0,
      };

      final detail = TopicDetailData.fromJson(json);

      expect(detail.isYouTubeVideo, isFalse);
      expect(detail.youtubeVideoId, isNull);
      expect(detail.youtubeUrl, isNull);
      expect(detail.durationSeconds, equals(0));
      expect(detail.position, isNull);
      expect(detail.channelName, isNull);
    });
  });
}
