import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';
import '../storage/local_storage.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders() {
    final token = LocalStorageService().getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _httpClient.get(uri, headers: _buildHeaders());
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unable to reach server ($baseUrl$endpoint): $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _httpClient.post(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unable to reach server ($baseUrl$endpoint): $e');
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _httpClient.put(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unable to reach server. Please check your connection: $e');
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _httpClient.patch(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unable to reach server. Please check your connection: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _httpClient.delete(uri, headers: _buildHeaders());
      return _processResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unable to reach server. Please check your connection: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic responseData;
    try {
      if (response.body.isNotEmpty) {
        responseData = jsonDecode(response.body);
      }
    } catch (_) {
      // Body not JSON
    }

    final serverMessage = responseData is Map
        ? (responseData['message'] ?? responseData['error'])?.toString()
        : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else if (response.statusCode == 401) {
      throw AuthException(
        serverMessage ?? 'Unauthorized. Please login again.',
        code: 'UNAUTHORIZED',
      );
    } else if (response.statusCode == 409) {
      throw AppException(
        serverMessage ?? 'Account with this email already exists.',
        code: 'CONFLICT',
      );
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw AppException(
        serverMessage ?? 'Invalid request (${response.statusCode})',
        code: response.statusCode.toString(),
      );
    } else {
      throw AppException(
        serverMessage ?? 'Server error occurred (${response.statusCode})',
        code: response.statusCode.toString(),
      );
    }
  }
}
