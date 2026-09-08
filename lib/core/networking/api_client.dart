import 'package:dio/dio.dart';
import '../../app/config/app_config.dart';
import '../storage/storage_service.dart';
import '../errors/failure.dart';

class ApiClient {
  final Dio _dio;
  final StorageService? _storageService;

  ApiClient({StorageService? storageService})
      : _storageService = storageService,
        _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    // 1. Auth Interceptor: Attaches Supabase / JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = _storageService;
          if (storage != null) {
            try {
              final token = await storage.read('auth_token');
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (_) {}
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          final storage = _storageService;
          if (e.response?.statusCode == 401 && storage != null) {
            // Clear invalid session on 401
            try {
              await storage.delete('auth_token');
            } catch (_) {}
          }
          return handler.next(e);
        },
      ),
    );

    // 2. Global Logging Interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ),
    );
  }

  Dio get rawDio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Failure _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      String message = 'Request failed';
      if (e.response?.data is Map) {
        final dataMap = e.response!.data as Map;
        message = (dataMap['error'] is Map ? dataMap['error']['message'] : null) ??
            dataMap['message'] ??
            dataMap['detail'] ??
            'Request failed';
      } else if (e.response?.data is String && (e.response!.data as String).isNotEmpty) {
        message = e.response!.data as String;
      }

      final msgLower = message.toLowerCase();
      final isQuota = statusCode == 429 ||
          msgLower.contains('quota') ||
          msgLower.contains('rate limit') ||
          msgLower.contains('resource_exhausted') ||
          msgLower.contains('too many requests');

      if (isQuota) {
        return QuotaFailure(
          'API usage limit reached (quota exceeded). Please try again later or verify your Gemini AI API key.',
        );
      }

      switch (statusCode) {
        case 400:
          return ValidationFailure(message.toString());
        case 401:
          return AuthFailure('Unauthorized. Please log in again.');
        case 403:
          return AuthFailure('Forbidden. Access denied.');
        case 404:
          return ServerFailure('Resource not found.');
        case 409:
          return ServerFailure('Conflict: $message');
        case 422:
          return ValidationFailure(message.toString());
        case 429:
          return QuotaFailure('Too many requests. API quota reached. Please slow down.');
        case 500:
        case 502:
        case 503:
          return ServerFailure('Server is waking up or temporarily unavailable. Please retry in a few seconds.');
        default:
          return ServerFailure('Unexpected error ($statusCode): $message');
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkFailure('Server request timed out. The server may be warming up from inactivity; please retry.');
    }
    return NetworkFailure('Network error. Please check your internet connection.');
  }
}
