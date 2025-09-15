import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:prestige_pos/auth/service/api_client.dart';

typedef SaveToHiveFunction<T> = Future<void> Function(T data);
typedef SaveListToHiveFunction<T> = Future<void> Function(List<T> data);
typedef LoadFromHiveFunction<T> = Future<T?> Function(); // For single item
typedef LoadListFromHiveFunction<T> = Future<List<T>?> Function();

class SharedService {
  late final ApiClient _apiClient;

  SharedService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<T?> fetchData<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic> json) parserFromJson,
    required ValueChanged<bool> setLoading,
    required ValueChanged<String> setError,
    required VoidCallback notifyListenersCallback,
    LoadFromHiveFunction<T>? loadFromHive,
    SaveToHiveFunction<T>? saveToHive,
    bool forceRefresh = false,
  }) async {
    setLoading(true);
    setError('');
    notifyListenersCallback();

    try {
      if (!forceRefresh && loadFromHive != null) {
        try {
          final T? localData = await loadFromHive();
          if (localData != null) {
            if (kDebugMode) {
              print("SharedService: Loaded data from Hive for $endpoint");
            }

            return localData;
          }
        } catch (e) {
          if (kDebugMode) {
            print("SharedService: Error loading from Hive for $endpoint: $e");
            // Continue to fetch from API
          }
        }
      }

      final String apiUrl = '${_apiClient.getApiUrl()}$endpoint';
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: queryParameters?.isNotEmpty == true
            ? queryParameters
            : null,
      );

      final response = await http
          .get(uri, headers: _apiClient.headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.toLowerCase() == 'null') {
          setError('Aucun résultat trouvé.');
          return null;
        }
        final decodedBody = json.decode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final T parsedData = parserFromJson(decodedBody);
          // 3. Save to Hive if a handler is provided
          if (saveToHive != null) {
            try {
              await saveToHive(parsedData);
              if (kDebugMode) {
                print("SharedService: Saved data to Hive for $endpoint");
              }
            } catch (e) {
              if (kDebugMode) {
                print("SharedService: Error saving to Hive for $endpoint: $e");
                // Don't let Hive error prevent returning fetched data
              }
            }
          }
          return parsedData;
        } else {
          setError('Format de données inattendu.');
          if (kDebugMode) {
            print(
              "SharedService: Expected Map<String, dynamic> but got ${decodedBody.runtimeType} for $endpoint",
            );
          }
          return null;
        }
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          setError('Accès non autorisé.');
        } else {
          setError(
            'Erreur de communication avec le serveur (Code: ${response.statusCode}).',
          );
        }
        if (kDebugMode) {
          print(
            "SharedService HTTP Error ${response.statusCode} for $endpoint: ${response.body}",
          );
        }
        return null;
      }
    } finally {
      setLoading(false);
      notifyListenersCallback();
    }
  }

  Future<List<T>?> fetchListData<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic> json) itemParserFromJson,
    required ValueChanged<bool> setLoading,
    required ValueChanged<String> setError,
    required VoidCallback notifyListenersCallback,
    LoadListFromHiveFunction<T>? loadListFromHive,
    SaveListToHiveFunction<T>? saveListToHive,
    bool forceRefresh = false,
  }) async {
    setLoading(true);
    setError('');
    notifyListenersCallback();

    try {
      if (!forceRefresh && loadListFromHive != null) {
        print("forceRefresh is $forceRefresh");
        try {
          final List<T>? localListData = await loadListFromHive();
          if (localListData != null && localListData.isNotEmpty) {
            if (kDebugMode) {
              print("SharedService: Loaded list from Hive for $endpoint");
            }
            return localListData;
          }
        } catch (e) {
          if (kDebugMode) {
            print(
              "SharedService: Error loading list from Hive for $endpoint: $e",
            );
          }
        }
      }

      final String apiUrl = '${_apiClient.getApiUrl()}$endpoint';
      print('API URL: $apiUrl');
      final Uri uri = Uri.parse(apiUrl).replace(
        queryParameters: queryParameters?.isEmpty ?? true
            ? null
            : queryParameters,
      );

      final http.Response response = await http
          .get(uri, headers: _apiClient.headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.toLowerCase() == 'null') {
          setError('');
          final List<T> emptyList = [];

          if (saveListToHive != null) {
            try {
              await saveListToHive(emptyList);
              if (kDebugMode) {
                print(
                  "SharedService: Saved empty list to Hive for $endpoint (cleared old)",
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print(
                  "SharedService: Error saving empty list to Hive for $endpoint: $e",
                );
              }
            }
          }
          return emptyList;
        }

        final decodedBody = json.decode(response.body);
        if (decodedBody is List) {
          if (decodedBody.isEmpty) {
            final List<T> emptyList = [];
            // 3b. Save empty list to Hive
            if (saveListToHive != null) {
              try {
                await saveListToHive(emptyList);
                if (kDebugMode) {
                  print(
                    "SharedService: Saved empty list to Hive for $endpoint",
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  print(
                    "SharedService: Error saving empty list to Hive for $endpoint: $e",
                  );
                }
              }
            }
            return emptyList;
          }

          final List<T> results = decodedBody.map((itemJson) {
            if (itemJson is Map<String, dynamic>) {
              return itemParserFromJson(itemJson);
            } else {
              final formatErrorMsg =
                  'Format de données inattendu pour un élément de la liste.';
              setError(formatErrorMsg);
              throw FormatException(formatErrorMsg, itemJson);
            }
          }).toList();

          if (saveListToHive != null) {
            try {
              await saveListToHive(results);
              if (kDebugMode) {
                print("SharedService: Saved list to Hive for $endpoint");
              }
            } catch (e) {
              if (kDebugMode) {
                print(
                  "SharedService: Error saving list to Hive for $endpoint: $e",
                );
              }
            }
          }
          return results;
        } else {
          setError('Format de données inattendu. Attendu une liste.');
          if (kDebugMode) {
            print(
              "SharedService: Expected List for $endpoint but got ${decodedBody.runtimeType}",
            );
          }
          return null;
        }
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          setError('Non autorisé. Veuillez vérifier vos identifiants.');
        } else if (response.statusCode == 404) {
          setError('Ressource non trouvée.');
          return []; // Return empty list for 404
        } else if (response.statusCode >= 500) {
          setError('Erreur du serveur. Veuillez réessayer plus tard.');
        } else {
          setError(
            'Erreur lors du chargement des données (Code: ${response.statusCode}).',
          );
        }
        if (kDebugMode) {
          print(
            "SharedService HTTP Error ${response.statusCode} for $endpoint: ${response.body}",
          );
        }
        return null; // Return null on HTTP error (unless it's a 404 for list)
      }
    } finally {
      setLoading(false);
      notifyListenersCallback();
    }
  }
}
