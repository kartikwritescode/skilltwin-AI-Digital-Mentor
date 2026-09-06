import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/models/resource.dart';
import '../../domain/repositories/library_repository.dart';
import 'mock_library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final ApiClient _apiClient;
  final MockLibraryRepository _fallback = MockLibraryRepository();

  LibraryRepositoryImpl(this._apiClient);

  @override
  Future<List<Resource>> getResources({String? query}) async {
    try {
      final response = await _apiClient.get('/resources', queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
      });
      if (response.data is List) {
        return (response.data as List).map((e) => Resource.fromJson(e)).toList();
      }
      return _fallback.getResources(query: query);
    } catch (_) {
      return _fallback.getResources(query: query);
    }
  }

  @override
  Future<Resource> uploadPdf(File file, String title) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'is_public': false,
        'file': await MultipartFile.fromFile(file.path, filename: title),
      });

      final response = await _apiClient.post('/resources/upload', data: formData);
      return Resource.fromJson(response.data);
    } catch (_) {
      return _fallback.uploadPdf(file, title);
    }
  }

  @override
  Future<Resource> addLink(String url, String title) async {
    try {
      final response = await _apiClient.post('/resources/link', data: {
        'url': url,
        'title': title,
      });
      return Resource.fromJson(response.data);
    } catch (_) {
      return _fallback.addLink(url, title);
    }
  }

  @override
  Future<Resource> createNote(String content, String title) async {
    try {
      final response = await _apiClient.post('/resources/note', data: {
        'content': content,
        'title': title,
      });
      return Resource.fromJson(response.data);
    } catch (_) {
      return _fallback.createNote(content, title);
    }
  }

  @override
  Future<void> deleteResource(String id) async {
    try {
      await _apiClient.delete('/resources/$id');
    } catch (_) {
      await _fallback.deleteResource(id);
    }
  }

  @override
  Future<Resource> getResourceDetails(String id) async {
    try {
      final response = await _apiClient.get('/resources/$id');
      return Resource.fromJson(response.data);
    } catch (_) {
      return _fallback.getResourceDetails(id);
    }
  }

  Future<List<Resource>> searchResources(String query, {int topK = 5}) async {
    try {
      final response = await _apiClient.post('/resources/search', data: {
        'query': query,
        'top_k': topK,
      });
      if (response.data is List) {
        return (response.data as List).map((e) => Resource.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
