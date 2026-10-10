import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../../../core/network/mock_backend_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/errors/app_exceptions.dart';

class AuthController extends ChangeNotifier {
  final AuthApiService _apiService;
  final MockBackendService _mockBackendService = MockBackendService();
  final LocalStorageService _storage = LocalStorageService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _pendingContact;

  AuthController({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiService();

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get pendingContact => _pendingContact;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearSuccess() {
    if (_successMessage != null) {
      _successMessage = null;
      notifyListeners();
    }
  }

  /// Check active session from local storage or backend
  Future<void> checkSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedToken = _storage.getString('auth_token');
      final savedUserJson = _storage.getString('user_profile');

      if (savedToken != null && savedToken.isNotEmpty) {
        if (savedUserJson != null && savedUserJson.isNotEmpty) {
          try {
            final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
            _user = UserModel.fromJson(userMap);
            _mockBackendService.setCurrentUser(_user);
          } catch (_) {}
        }

        // Try to fetch latest user info from backend
        try {
          final liveUser = await _apiService.getCurrentUser();
          _user = liveUser;
          _mockBackendService.setCurrentUser(_user);
          await _storage.setString('user_profile', jsonEncode(_user!.toJson()));
        } catch (_) {
          // If offline or network error, retain cached user
        }
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user with name, email, phone, and password
  Future<bool> register({
    required String name,
    required String email,
    String? phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      _user = result.user;
      _mockBackendService.setCurrentUser(_user);

      if (result.token.isNotEmpty) {
        await _storage.setString('auth_token', result.token);
      }
      await _storage.setString('user_profile', jsonEncode(_user!.toJson()));

      _successMessage = result.message;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please check your connection and try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(
        email: email,
        password: password,
      );

      _user = result.user;
      _mockBackendService.setCurrentUser(_user);

      if (result.token.isNotEmpty) {
        await _storage.setString('auth_token', result.token);
      }
      await _storage.setString('user_profile', jsonEncode(_user!.toJson()));

      _successMessage = result.message;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed. Please check your credentials and server connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Request OTP for verification
  Future<bool> requestOtp(String emailOrPhone) async {
    _isLoading = true;
    _errorMessage = null;
    _pendingContact = emailOrPhone;
    notifyListeners();

    try {
      final success = await _mockBackendService.requestOtp(emailOrPhone);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String otp) async {
    if (_pendingContact == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _mockBackendService.verifyOtp(_pendingContact!, otp);
      _user = user;
      await _storage.setString('auth_token', 'jwt_session_token_${user.id}');
      await _storage.setString('user_profile', jsonEncode(_user!.toJson()));
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Authentication failed. Please check the OTP code.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({String? name, String? phone, String? avatarUrl}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateProfile(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      _user = updatedUser;
      _mockBackendService.setCurrentUser(_user);
      await _storage.setString('user_profile', jsonEncode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Log out user
  Future<void> logout() async {
    await _storage.remove('auth_token');
    await _storage.remove('user_profile');
    _user = null;
    _pendingContact = null;
    _mockBackendService.setCurrentUser(null);
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
