import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/errors/api_error_handler.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, TokenStorage? tokenStorage})
    : _authService = authService ?? AuthService(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final AuthService _authService;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  UserModel? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> login({required String email, required String password}) async {
    return _authenticate(
      () => _authService.login(email: email, password: password),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _authenticate(
      () => _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  Future<void> checkAuth() async {
    _setLoading(true);

    try {
      final hasToken = await _tokenStorage.hasToken();

      if (!hasToken) {
        _user = null;
        return;
      }

      _user = await _authService.getUser();
      _errorMessage = null;
    } catch (_) {
      _user = null;
      await _tokenStorage.clearToken();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
    } catch (_) {
      // Token yine de temizlenir; oturum cihaz tarafinda kapanmis olur.
    } finally {
      await _tokenStorage.clearToken();
      _user = null;
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({required String name, File? image}) async {
    _setLoading(true);

    try {
      _user = await _authService.updateProfile(name: name, image: image);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = ApiErrorHandler.messageFrom(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _authenticate(Future<AuthResponse> Function() request) async {
    _setLoading(true);

    try {
      final authResponse = await request();
      await _tokenStorage.saveToken(authResponse.token);
      _user = await _authService.getUser();
      _errorMessage = null;
      return true;
    } catch (error) {
      _user = null;
      await _tokenStorage.clearToken();
      _errorMessage = ApiErrorHandler.messageFrom(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
