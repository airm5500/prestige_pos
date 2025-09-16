import 'package:flutter/foundation.dart';
import 'package:prestige_pos/model/vente/remise.dart';
import 'package:prestige_pos/service/remise_service.dart';

class RemiseProvider extends ChangeNotifier {
  final RemiseService _service;

  RemiseProvider(this._service);

  bool _isLoading = false;
  String? _errorMessage;
  List<Remise> _remises = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<Remise> get remises => List.unmodifiable(_remises);

  Future<void> fetch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.fetchAll();

    if (response.success) {
      _remises = response.data ?? [];
    } else {
      _errorMessage = response.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearProduits() {
    _remises = [];
    notifyListeners();
  }
}
