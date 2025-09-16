import 'dart:convert';

import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/service/shared_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeReglementService {
  final SharedService _sharedService;

  ModeReglementService({required ApiClient apiClient})
    : _sharedService = SharedService(apiClient: apiClient);

  Future<ApiResponse<List<ModeReglement>>> fetchAll(
  ) async {
    final storedData = await _loadModeReglementStorage();
    if (storedData != null && storedData.isNotEmpty) {
      return ApiResponse.success(storedData);
    }
    final response = await _sharedService.getData<ModeReglement>(
      endpoint: '/common/reglements',
      itemParserFromJson: (json) => ModeReglement.fromJson(json),
    );
    if (response.success) {
      await _saveAllModeReglement(response.data!);
    }
    return response;
  }

  Future<List<ModeReglement>?> _loadModeReglementStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('mode_reglements');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final loadedData = jsonList
          .map((json) => ModeReglement.fromJson(json))
          .toList();

      return loadedData;
    }
    return null;
  }

  Future<void> _saveAllModeReglement(List<ModeReglement> modeReglements) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      modeReglements.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('mode_reglements', jsonString);
  }
}
