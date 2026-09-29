import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../../core/network/mock_backend_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/errors/app_exceptions.dart';

class AuthController extends ChangeNotifier {
  final MockBackendService _backendService = MockBackendService();
  final LocalStorageService _storage = LocalStorageService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _pendingContact;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get pendingContact => _pendingContact;

  Future<void> checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = _storage.getString('auth_token');
      if (savedToken != null && savedToken.isNotEmpty) {
        _user = _backendService.currentUser;
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithPassword(String usernameOrEmail, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _backendService.signInWithPassword(usernameOrEmail, password);
      _user = user;
      await _storage.setString('auth_token', 'jwt_session_token_${user.id}');
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Authentication failed. Please check your credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestOtp(String emailOrPhone) async {
    _isLoading = true;
    _errorMessage = null;
    _pendingContact = emailOrPhone;
    notifyListeners();

    try {
      final success = await _backendService.requestOtp(emailOrPhone);
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

  Future<bool> verifyOtp(String otp) async {
    if (_pendingContact == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _backendService.verifyOtp(_pendingContact!, otp);
      _user = user;
      await _storage.setString('auth_token', 'jwt_session_token_${user.id}');
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

  Future<void> logout() async {
    await _storage.remove('auth_token');
    _user = null;
    _pendingContact = null;
    notifyListeners();
  }
}
