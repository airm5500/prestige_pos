import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/error/problem_detail.dart';

class SharedService {
  late final ApiClient _apiClient;

  SharedService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<List<T>>> getData<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic> json) itemParserFromJson,
  }) async {
    try {
      final String apiUrl = '${_apiClient.getApiUrl()}$endpoint';
      final Uri uri = Uri.parse(apiUrl).replace(
        queryParameters: queryParameters?.isNotEmpty == true
            ? queryParameters
            : null,
      );

      final http.Response response = await http
          .get(uri, headers: _apiClient.headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.toLowerCase() == 'null') {
          return ApiResponse.success([]);
        }

        final decodedBody = json.decode(response.body);
        if (decodedBody is List) {
          final results = decodedBody.map<T>((itemJson) {
            if (itemJson is Map<String, dynamic>) {
              return itemParserFromJson(itemJson);
            } else {
              throw const FormatException('Format JSON inattendu');
            }
          }).toList();

          return ApiResponse.success(results);
        } else {
          return ApiResponse.error('Format inattendu : liste attendue.');
        }
      } else {
        return _handleHttpError(response, endpoint);
      }
    } catch (e) {
      return ApiResponse.error('Exception: $e');
    }
  }

  Future<ApiResponse<T>> postData<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? itemParserFromJson,
  }) async {
    try {
      final uri = Uri.parse('${_apiClient.getApiUrl()}$endpoint');
      final response = await http
          .post(uri, headers: _apiClient.headers, body: json.encode(body))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (itemParserFromJson != null && response.body.isNotEmpty) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            final decodeObject = itemParserFromJson(decoded);
            return ApiResponse.success(decodeObject);
          } else {
            return ApiResponse.error('Format inattendu : objet JSON attendu.');
          }
        }
        return ApiResponse.success(null as T);
      } else {
        return _handleHttpError(response, endpoint);
      }
    } catch (e) {
      return ApiResponse.error('Exception: $e');
    }
  }

  ApiResponse<T> _handleHttpError<T>(http.Response response, String endpoint) {
    print(response.body);
    switch (response.statusCode) {
      
      case 400:
        final decodedBody = utf8.decode(response.bodyBytes);
        final decoded = json.decode(decodedBody);
        final ProblemDetail detail = ProblemDetail.fromJson(decoded);
        return ApiResponse.withProblemDetail(detail);
      case 401:
      case 403:
        return ApiResponse.error(
          'Non autorisé. Veuillez vérifier vos identifiants.',
        );
      case 404:
        return ApiResponse.error('Ressource non trouvée.');
      default:
        if (response.statusCode >= 500) {
          return ApiResponse.error(
            'Erreur serveur. Veuillez réessayer plus tard.',
          );
        }
        return ApiResponse.error(
          'Erreur inattendue (Code: ${response.statusCode}).',
        );
    }
  }

  Future<ApiResponse<T>> deleteData<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    T Function(Map<String, dynamic>)? itemParserFromJson,
  }) async {
    try {
      final uri = Uri.parse('${_apiClient.getApiUrl()}$endpoint').replace(
        queryParameters: queryParameters?.isNotEmpty == true
            ? queryParameters
            : null,
      );

      final response = await http
          .delete(uri, headers: _apiClient.headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (itemParserFromJson != null && response.body.isNotEmpty) {
          final decoded = json.decode(response.body);
          return ApiResponse.success(itemParserFromJson(decoded));
        }
        return ApiResponse.success(null as T);
      } else {
        return _handleHttpError(response, endpoint);
      }
    } catch (e) {
      return ApiResponse.error('Exception: $e');
    }
  }

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic> json) itemParserFromJson,
  }) async {
    try {
      final String apiUrl = '${_apiClient.getApiUrl()}$endpoint';
      final Uri uri = Uri.parse(apiUrl).replace(
        queryParameters: queryParameters?.isNotEmpty == true
            ? queryParameters
            : null,
      );

      final http.Response response = await http
          .get(uri, headers: _apiClient.headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.toLowerCase() == 'null') {
          return ApiResponse.success(null as T);
        }

        final decodedBody = json.decode(response.body);
        print(decodedBody);
        if (decodedBody is Map<String, dynamic>) {
          final result = itemParserFromJson(decodedBody);
          return ApiResponse.success(result);
        } else {
          return ApiResponse.error('Format inattendu : liste attendue.');
        }
      } else {
        return _handleHttpError(response, endpoint);
      }
    } catch (e) {
      return ApiResponse.error('Exception: $e');
    }
  }
}
