import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/model/vente/mode_reglement.dart';
import 'package:prestige_pos/auth/model/vente/nature_vente.dart';
import 'package:prestige_pos/auth/model/vente/remise.dart';
import 'package:prestige_pos/auth/model/vente/type_vente.dart';
import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/auth/service/service_state_wrapper.dart';
import 'package:prestige_pos/auth/service/shared_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetaDataService extends BaseServiceNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  final SharedService _sharedService;
  List<NatureVente> _natureVentes = [];
  List<TypeVente> _typeVentes = [];
  List<ModeReglement> _modeReglements = [];
  List<Remise> _remises = [];

  bool _isDisposed = false;

  List<NatureVente> get natureVentes => _natureVentes;

  List<TypeVente> get typeVentes => _typeVentes;

  List<ModeReglement> get modeReglements => _modeReglements;

  List<Remise> get remises => _remises;

  @override
  bool get isLoading => _isLoading;

  @override
  String get errorMessage => _errorMessage;

  @override
  bool get hasData => _modeReglements.isNotEmpty || _remises.isNotEmpty;

  MetaDataService({required ApiClient apiClient})
    : _sharedService = SharedService(apiClient: apiClient);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Notifie seulement si le service n'est pas disposé et si on n'est pas en phase de build
  void _safeNotifyListeners() {
    if (!_isDisposed &&
        !WidgetsBinding.instance.lifecycleState.toString().contains(
          'inactive',
        )) {
      notifyListeners();
    }
  }

  Future<void> fetchAllMetaData(bool refresh) async {
    await Future.wait([
      _fetchModeReglement(refresh),
      //_fetchRemises(refresh),
    ]);
  }

  Future<void> _fetchNatureVente(bool refresh) async {
    final result = await _sharedService.fetchListData<NatureVente>(
      endpoint: '/common/nature-ventes',
      itemParserFromJson: (jsonData) => NatureVente.fromJson(jsonData),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _errorMessage = error,
      notifyListenersCallback: _safeNotifyListeners,
      saveListToHive: _saveAllNatureVente,
      loadListFromHive: _loadNatureVenteStorage,
      forceRefresh: refresh,
    );
    if (result != null) {
      _natureVentes = result;
    }
  }

  Future<List<NatureVente>?> _loadNatureVenteStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('nature_ventes');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final loadedData = jsonList
          .map((json) => NatureVente.fromJson(json))
          .toList();
      _natureVentes = loadedData;
      return loadedData;
    }
    return null;
  }

  Future<void> _saveAllNatureVente(List<NatureVente> natureVentes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      natureVentes.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('nature_ventes', jsonString);
  }

  Future<void> _fetchTypeVente(bool refresh) async {
    final result = await _sharedService.fetchListData<TypeVente>(
      endpoint: '/common/type-ventes',
      itemParserFromJson: (jsonData) => TypeVente.fromJson(jsonData),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _errorMessage = error,
      notifyListenersCallback: _safeNotifyListeners,
      saveListToHive: _saveAllTypeVente,
      loadListFromHive: _loadTypeVenteStorage,
      forceRefresh: refresh,
    );
    if (result != null) {
      _typeVentes = result;
    }
  }

  Future<List<TypeVente>?> _loadTypeVenteStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('type_ventes');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final loadedData = jsonList
          .map((json) => TypeVente.fromJson(json))
          .toList();
      _typeVentes = loadedData;
      return loadedData;
    }
    return null;
  }

  Future<void> _saveAllTypeVente(List<TypeVente> typeVentes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(typeVentes.map((e) => e.toJson()).toList());
    await prefs.setString('type_ventes', jsonString);
  }

  Future<void> _fetchModeReglement(bool refresh) async {
    final result = await _sharedService.fetchListData<ModeReglement>(
      endpoint: '/common/reglements',
      itemParserFromJson: (jsonData) => ModeReglement.fromJson(jsonData),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _errorMessage = error,
      notifyListenersCallback: _safeNotifyListeners,
      saveListToHive: _saveAllModeReglement,
      loadListFromHive: _loadModeReglementStorage,
      forceRefresh: refresh,
    );
    if (result != null) {
      _modeReglements = result;
    }
    print('ModeReglements fetched: ${_modeReglements}');
  }

  Future<List<ModeReglement>?> _loadModeReglementStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('mode_reglements');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final loadedData = jsonList
          .map((json) => ModeReglement.fromJson(json))
          .toList();
      _modeReglements = loadedData;
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

  Future<void> _fetchRemises(bool refresh) async {
    final result = await _sharedService.fetchListData<Remise>(
      endpoint: '/common/remises',
      itemParserFromJson: (jsonData) => Remise.fromJson(jsonData),
      setLoading: (loading) => _isLoading = loading,
      setError: (error) => _errorMessage = error,
      notifyListenersCallback: _safeNotifyListeners,
      saveListToHive: _saveAllRemises,
      loadListFromHive: _loadRemisesStorage,
      forceRefresh: refresh,
    );
    if (result != null) {
      _remises = result;
    }
  }

  Future<List<Remise>?> _loadRemisesStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('remises');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final loadedData = jsonList.map((json) => Remise.fromJson(json)).toList();
      _remises = loadedData;
      return loadedData;
    }
    return null;
  }

  Future<void> _saveAllRemises(List<Remise> remises) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(remises.map((e) => e.toJson()).toList());
    await prefs.setString('remises', jsonString);
  }
}
