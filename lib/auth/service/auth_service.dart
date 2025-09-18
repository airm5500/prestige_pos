import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/service/api_client.dart';

import 'package:prestige_pos/auth/service/jwt_service.dart';
import 'package:prestige_pos/model/client_user.dart';

class AuthService extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  ClientUser? _currentUser;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  ClientUser? get currentUser => _currentUser;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> loginWithJwt(String username, String password) async {
    _setLoading(true);
    _setError('');

    try {
      final token = await JwtService().getToken(username, password);
      if (token != null) {
        final apiClient = await ApiClient.init();
        apiClient.token = token;
        apiClient.username = username;
        apiClient.password = password;
        _isAuthenticated = true;
        _currentUser = apiClient.currentUser;
        notifyListeners();
      } else {
        _isAuthenticated = false;
        _setError('Échec de la connexion. Veuillez vérifier vos identifiants.');
      }
    } catch (e) {
      _isAuthenticated = false;
      _setError('Une erreur inattendue s\'est produite');
    } finally {
      _setLoading(false);
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    final apiClient = await ApiClient.init();
    _currentUser = null;
    _isAuthenticated = false;
    apiClient.token = null;
    apiClient.username = null;
    apiClient.password = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final apiClient = await ApiClient.init();
    if (!apiClient.rememberMe) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final username = apiClient.username;
      final password = apiClient.password;

      if (username != null && password != null) {
        final token = await JwtService().getToken(username, password);

        if (token != null) {
          apiClient.token = token;
          _isAuthenticated = true;
          _errorMessage = '';
        } else {
          _isAuthenticated = false;
          _errorMessage =
              'Connexion automatique impossible, veuillez vous reconnecter.';
        }
      }
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Erreur lors de la connexion automatique';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
