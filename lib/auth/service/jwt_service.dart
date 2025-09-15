import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prestige_pos/auth/service/api_client.dart';

class JwtService {
  Future<String?> getToken(String username, String password) async {
    final apiClient = await ApiClient.init();
    final response = await http.post(
      Uri.parse(apiClient.authUrl),
      //  Uri.parse('http://192.168.1.51:8780/auth/token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      //TODO retrieve user info
      print(jsonResponse);
      return jsonResponse['access_token'];
    } else {
      return null;//TODO handle error
    }
  }
}
