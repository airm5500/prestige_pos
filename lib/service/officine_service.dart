import 'dart:convert';

import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/vente/officine.dart';
import 'package:prestige_pos/service/shared_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfficineService {
  final SharedService _sharedService;

  OfficineService({required ApiClient apiClient})
    : _sharedService = SharedService(apiClient: apiClient);

  Future<ApiResponse<Officine?>> find() async {
    final storedData = await _loadOfficine();

    if (storedData == null) {
      final response = await _sharedService.get<Officine>(
        endpoint: '/common/officine',
        itemParserFromJson: (json) => Officine.fromJson(json),
      );

      if (response.data != null) {
        await _saveOfficine(response.data!);
        return response;
      }
      return ApiResponse.success(storedData);
    } else {
      return ApiResponse.success(storedData);
    }
  }

  Future<Officine?> _loadOfficine() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('officine');
    if (jsonString != null) {
      final Map<String, dynamic> jsonObj = json.decode(jsonString);
      final loadedData = Officine.fromJson(jsonObj);
      return loadedData;
    }
    return null;
  }

  Future<void> _saveOfficine(Officine officine) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(officine.toJson());
    await prefs.setString('officine', jsonString);
  }
}
