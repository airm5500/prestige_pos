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
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await JwtService().getToken(username, password);
      print('Token---: $token');
      if (token != null) {
        final apiClient = await ApiClient.init();
        apiClient.token = token;

        _isAuthenticated = true;
        _errorMessage = '';
      } else {
        _isAuthenticated = false;
        _errorMessage =
            'Échec de la connexion. Veuillez vérifier vos identifiants.';
      }
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Une erreur inattendue s\'est produite';
      print('Erreur lors de la connexion : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = '';
    // await ApiClient().clearCredentials();

    _isAuthenticated = false;
    notifyListeners();
  }
}
