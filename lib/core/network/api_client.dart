import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';
import '../storage/local_storage.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    this.baseUrl = 'https://api.pystudio.dev/v1',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

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
      throw NetworkException('Failed GET request to $endpoint: $e');
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
      throw NetworkException('Failed POST request to $endpoint: $e');
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
      throw NetworkException('Failed PUT request to $endpoint: $e');
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
      throw NetworkException('Failed PATCH request to $endpoint: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _httpClient.delete(uri, headers: _buildHeaders());
      return _processResponse(response);
    } catch (e) {
      throw NetworkException('Failed DELETE request to $endpoint: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw AuthException('Unauthorized. Please login again.', code: 'UNAUTHORIZED');
    } else if (response.statusCode == 409) {
      throw FileConflictException(
        'File conflict detected on server.',
        serverRevision: 0,
        localRevision: 0,
      );
    } else {
      throw AppException(
        'Server returned code ${response.statusCode}: ${response.body}',
        code: response.statusCode.toString(),
      );
    }
  }
}
