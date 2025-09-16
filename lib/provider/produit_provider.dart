import 'package:flutter/foundation.dart';
import 'package:prestige_pos/model/vente/search_produit_result.dart';
import 'package:prestige_pos/service/produit_service.dart';

class ProduitProvider extends ChangeNotifier {
  final ProduitService _service;

  ProduitProvider(this._service);

  bool _isLoading = false;
  String? _errorMessage;
  List<SearchProduitResult> _produits = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SearchProduitResult> get produits => List.unmodifiable(_produits);

  Future<void> fetchProduits({required String search , int? pageSize}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.fetchAll(search, pageSize);

    if (response.success) {
      _produits = response.data ?? [];
    } else {
      _errorMessage = response.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearProduits() {
    _produits = [];
    notifyListeners();
  }

}
