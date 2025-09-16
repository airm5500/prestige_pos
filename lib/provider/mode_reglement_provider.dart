import 'package:flutter/foundation.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/service/mode_reglement_service.dart';

class ModeReglementProvider extends ChangeNotifier {
  final ModeReglementService _service;

  ModeReglementProvider(this._service);

  bool _isLoading = false;
  String? _errorMessage;
  List<ModeReglement> _modeReglements = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<ModeReglement> get modeReglements => List.unmodifiable(_modeReglements);

  Future<void> fetch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.fetchAll();

    if (response.success) {
      _modeReglements = response.data ?? [];
    } else {
      _errorMessage = response.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearProduits() {
    _modeReglements = [];
    notifyListeners();
  }
}
