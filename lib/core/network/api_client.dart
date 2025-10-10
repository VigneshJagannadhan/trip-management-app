import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Optional: Add interceptors
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return _processResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _processResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  dynamic _processResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
        throw UnauthorisedException(response.data.toString());
      case 500:
      default:
        throw FetchDataException(
          'Error occurred with status code: ${response.statusCode}',
        );
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw FetchDataException('Connection timeout');
    } else if (e.response != null) {
      _processResponse(e.response!);
    } else {
      throw FetchDataException(e.message ?? 'Unexpected error');
    }
  }
}
