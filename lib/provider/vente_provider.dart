import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/client_user.dart';
import 'package:prestige_pos/model/error/problem_detail.dart';
import 'package:prestige_pos/model/vente/add_remise.dart';
import 'package:prestige_pos/model/vente/add_vente_item.dart';
import 'package:prestige_pos/model/vente/cloture_vente.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/model/vente/finalyse_response.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/model/vente/vente.dart';
import 'package:prestige_pos/service/vente_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VenteProvider extends ChangeNotifier {
  final VenteService _venteService;

  VenteProvider({required VenteService venteService})
      : _venteService = venteService;

  CreateResponse? _currentVente;

  CreateResponse? get currentVente => _currentVente;

  bool _isLoading = false;
  bool _canUpdatePrice = true;

  bool get canUpdatePrice => _canUpdatePrice;

  bool get isLoading => _isLoading;

  String? _errorMessage;
  ProblemDetail? _errorDetail;

  ProblemDetail? get errorDetail => _errorDetail;

  String? get errorMessage => _errorMessage;

  FinalyseResponse? _finalyseResponse;

  FinalyseResponse? get finalyseResponse => _finalyseResponse;

  ModeReglement? _selectedModeReglement;

  ModeReglement? get selectedModeReglement => _selectedModeReglement;

  bool isFromPrevente = false;

  Future<ClientUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('currentUser');
    if (jsonString != null) {
      final Map<String, dynamic> jsonObj = json.decode(jsonString);
      return ClientUser.fromJson(jsonObj);
    }
    return null;
  }

  void loadVente(CreateResponse vente) {
    _currentVente = vente;
    isFromPrevente = true;
    notifyListeners();
  }

  void resetPreventeFlag() {
    isFromPrevente = false;
  }

  void updateCanUpdatePrice(bool value) {
    _canUpdatePrice = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message, [ProblemDetail? detail]) {
    _errorMessage = message;
    _errorDetail = detail;
    notifyListeners();
  }

  void _setFinalyseResponse(FinalyseResponse? response) {
    _finalyseResponse = response;
    if (_currentVente != null && response != null) {
      _currentVente!.status = 'CLOSED';
    }

    notifyListeners();
  }

  void _setCurrentVente(CreateResponse? vente) {
    _currentVente = vente;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _errorDetail = null;
  }

  void createNewVente() {
    _setCurrentVente(null);
    _setFinalyseResponse(null);
    clearError();
    resetPreventeFlag();
  }

  void updateSelectedModeReglement(ModeReglement mode) {
    _selectedModeReglement = mode;
    notifyListeners();
  }

  Future<void> createVno(Vente vente) async {
    await _execute(
      () => _venteService.createVno(vente),
      onSuccess: _setCurrentVente,
    );
  }

  Future<void> addItem(AddVenteItem item) async {
    await _execute(
      () => _venteService.addItem(item),
      onSuccess: _setCurrentVente,
    );
  }

  Future<void> removeItem(String itemId) async {
    await _execute(
      () => _venteService.removeItem(itemId),
      onSuccess: _setCurrentVente,
    );
  }

  Future<void> updateItem(AddVenteItem item) async {
    await _execute(
      () => _venteService.updateItem(item),
      onSuccess: _setCurrentVente,
    );
  }

  Future<void> addRemise(AddRemise remise) async {
    await _execute(
      () => _venteService.addRemise(remise),
      onSuccess: _setCurrentVente,
    );
  }

  Future<FinalyseResponse?> finalizeVno(ClotureVente clotureVente) async {
    _setLoading(true);
    clearError();
    final response = await _venteService.finalyseVno(clotureVente);
    _setLoading(false);

    if (response.success) {
      _setFinalyseResponse(response.data);
      return response.data;
    } else {
      _setError(response.error ?? 'Erreur lors de la création', response.body);
      return null;
    }
  }

  Future<void> _execute<T>(
    Future<ApiResponse<T>> Function() action, {
    Function(T? data)? onSuccess,
  }) async {
    _setLoading(true);
    clearError();
    final response = await action();
    _setLoading(false);
    if (response.success) {
      if (onSuccess != null) {
        onSuccess(response.data);
      }
    } else {
      _setError(response.error ?? 'Erreur inconnue', response.body);
    }
  }
}
