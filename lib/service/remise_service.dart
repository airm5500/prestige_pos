import 'dart:convert';

import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/model/vente/remise.dart';
import 'package:prestige_pos/service/shared_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemiseService {
  final SharedService _sharedService;

  RemiseService({required ApiClient apiClient})
    : _sharedService = SharedService(apiClient: apiClient);

  Future<ApiResponse<List<Remise>>> fetchAll(
  ) async {
    final storedData = await _loadRemiseStorage();
    if (storedData != null && storedData.isNotEmpty) {
      return ApiResponse.success(storedData);
    }
    final response = await _sharedService.getData<Remise>(
      endpoint: '/common/remises',
      itemParserFromJson: (json) => Remise.fromJson(json),
    );
    if (response.success) {
      await _saveAllRemise(response.data!);
    }
    return response;
  }

  Future<List<Remise>?> _loadRemiseStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('remises');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final loadedData = jsonList.map((json) => Remise.fromJson(json)).toList();

      return loadedData;
    }
    return null;
  }

  Future<void> _saveAllRemise(List<Remise> remises) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(remises.map((e) => e.toJson()).toList());
    await prefs.setString('remises', jsonString);
  }
}
