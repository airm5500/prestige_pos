import 'package:flutter/foundation.dart';
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/vente/add_remise.dart';
import 'package:prestige_pos/model/vente/add_vente_item.dart';
import 'package:prestige_pos/model/vente/cloture_vente.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/model/vente/finalyse_response.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/model/vente/vente.dart';
import 'package:prestige_pos/service/vente_service.dart';

class VenteProvider extends ChangeNotifier {
  final VenteService _venteService;

  VenteProvider({required VenteService venteService})
    : _venteService = venteService;

  Vente? _currentVenteToPrint;

  Vente? get currentVenteToPrint => _currentVenteToPrint;

  CreateResponse? _currentVente;

  CreateResponse? get currentVente => _currentVente;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  FinalyseResponse? _finalyseResponse;

  FinalyseResponse? get finalyseResponse => _finalyseResponse;

  ModeReglement? _selectedModeReglement;

  ModeReglement? get selectedModeReglement => _selectedModeReglement;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setFinalyseResponse(FinalyseResponse? response) {
    _finalyseResponse = response;
    notifyListeners();
  }

  void _setCurrentVenteToPrint(Vente? vente) {
    _currentVenteToPrint = vente;
    notifyListeners();
  }

  void _setCurrentVente(CreateResponse? vente) {
    _currentVente = vente;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void createNewVente() {
    _setCurrentVente(null);
    _setFinalyseResponse(null);
    _clearError();
  }

  void updateSelectedModeReglement(ModeReglement mode) {
    _selectedModeReglement = mode;
    notifyListeners();
  }

  /// specifique pour la recherche d'une vente et d'impression
  /* Future<void> find(String saleId) async {
    _setLoading(true);
    final response = await _venteService.find(saleId);
    _setLoading(false);

    if (response.success) {
      _setCurrentVenteToPrint(response.data);
    } else {
      _setError(response.error ?? 'Erreur inconnue');
    }
  }*/

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

  Future<void> finalizeVno(ClotureVente clotureVente) async {
    _setLoading(true);
    _clearError();
    final response = await _venteService.finalyseVno(clotureVente);
    _setLoading(false);

    if (response.success) {
      _setFinalyseResponse(response.data);
    } else {
      _setError(response.error ?? 'Erreur lors de la création');
    }
  }

  Future<void> _execute<T>(
    Future<ApiResponse<T>> Function() action, {
    Function(T? data)? onSuccess,
  }) async {
    _setLoading(true);
    _clearError();
    final response = await action();
    _setLoading(false);
    if (response.success) {
      if (onSuccess != null) {
        onSuccess(response.data);
      }
    } else {
      _setError(response.error ?? 'Erreur inconnue');
    }
  }
}
