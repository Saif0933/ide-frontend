import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthResponse {
  final UserModel user;
  final String token;
  final String message;

  AuthResponse({
    required this.user,
    required this.token,
    required this.message,
  });
}

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Register new user on backend API
  Future<AuthResponse> register({
    required String name,
    required String email,
    String? phone,
    required String password,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (phone != null && phone.isNotEmpty) {
      body['phone'] = phone;
    }

    final response = await _apiClient.post(
      ApiConstants.register,
      body: body,
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      final user = UserModel.fromJson(response['data'] as Map<String, dynamic>);
      final token = response['token']?.toString() ?? '';
      final message = response['message']?.toString() ?? 'Registration successful';
      return AuthResponse(user: user, token: token, message: message);
    }

    throw AppException('Unexpected server response during registration');
  }

  /// Log in existing user with email and password on backend API
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      final user = UserModel.fromJson(response['data'] as Map<String, dynamic>);
      final token = response['token']?.toString() ?? '';
      final message = response['message']?.toString() ?? 'Login successful';
      return AuthResponse(user: user, token: token, message: message);
    }

    throw AppException('Unexpected server response during login');
  }

  /// Fetch authenticated user details
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.me);
    if (response is Map<String, dynamic> && response['data'] != null) {
      return UserModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw AppException('Failed to fetch user profile');
  }

  /// Update user profile
  Future<UserModel> updateProfile({String? name, String? phone, String? avatarUrl}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    final response = await _apiClient.put(
      ApiConstants.profile,
      body: body,
    );

    if (response is Map<String, dynamic> && response['data'] != null) {
      return UserModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw AppException('Failed to update profile');
  }
}
