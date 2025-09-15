import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:http/http.dart' as http;
class VenteService with ChangeNotifier {
  late final ApiClient _apiClient;

  VenteService({ApiClient? apiClient})
    : _apiClient = (apiClient ?? ApiClient.init()) as ApiClient;

Future<http.Response?> postData({
  required String endpoint,
  required Object payload,
  required ValueChanged<bool> setLoading,
  required ValueChanged<String> setError,
  required VoidCallback notifyListenersCallback,
  Duration timeoutDuration = const Duration(
    seconds: 30,
  ),
}) async {
  setLoading(true);
  setError('');
  notifyListenersCallback();

  try {
    final String apiUrl = '${_apiClient.getApiUrl()}$endpoint';
    final Uri uri = Uri.parse(apiUrl);

    final http.Response response = await http
        .post(
      uri,
      headers: _apiClient.headers,
      body: json.encode(
        payload,
      ),
    )
        .timeout(timeoutDuration);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _handleHttpError(response, setError, endpoint);
    }
    return response; // Return the response for the caller to process
  } finally {
    setLoading(false);
    notifyListenersCallback(); // Notify loading finished
  }
}

void _handleHttpError(
    http.Response response,
    ValueChanged<String> setError,
    String endpoint) {
     print(response);
  if (response.statusCode == 401 || response.statusCode == 403) {
    setError('Non autorisé. Veuillez vérifier vos identifiants.');
  }
  else if (response.statusCode == 400 ) {
   // response.message
    //response.errorKey // TODO handle this according to backend implementation
    setError('Ressource non trouvée.');
  }
  else if (response.statusCode == 404 ) {
    setError('Ressource non trouvée.');
  } else if (response.statusCode >= 500) {
    setError('Erreur du serveur. Veuillez réessayer plus tard.');
  } else {
    setError(
      'Erreur lors du chargement des données (Code: ${response.statusCode}).',
    );
  }

}
}