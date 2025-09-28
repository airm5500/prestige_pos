import 'package:flutter/foundation.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/service/vente_data_service.dart';

class PreventeProvider extends ChangeNotifier {
  final VenteDataService _service;

  PreventeProvider(this._service);

  bool _isLoading = false;
  String? _errorMessage;
  List<CreateResponse> _preventes = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<CreateResponse> get preventes => List.unmodifiable(_preventes);

  Future<void> fetch(String? search) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.fetchAll(search);

    if (response.success) {
      _preventes = response.data ?? [];
    } else {
      _errorMessage = response.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _preventes = [];
    notifyListeners();
  }
}
