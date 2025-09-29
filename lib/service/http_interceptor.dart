import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prestige_pos/ui/login/login_screen.dart';
import 'package:prestige_pos/utils/navigation_service.dart';

class InterceptedClient extends http.BaseClient {
  final http.Client _inner;

  InterceptedClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).then((response) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        _handleUnauthorized();
      }
      return response;
    });
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return _inner.get(url, headers: headers).then((response) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        _handleUnauthorized();
      }
      return response;
    });
  }

  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _inner.post(url, headers: headers, body: body, encoding: encoding).then((response) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        _handleUnauthorized();
      }
      return response;
    });
  }

  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _inner.put(url, headers: headers, body: body, encoding: encoding).then((response) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        _handleUnauthorized();
      }
      return response;
    });
  }

  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _inner.delete(url, headers: headers, body: body, encoding: encoding).then((response) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        _handleUnauthorized();
      }
      return response;
    });
  }

  void _handleUnauthorized() {
    NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }
}
