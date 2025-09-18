import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/vente/add_remise.dart';
import 'package:prestige_pos/model/vente/add_vente_item.dart';
import 'package:prestige_pos/model/vente/cloture_vente.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/model/vente/finalyse_response.dart';
import 'package:prestige_pos/model/vente/vente.dart';
import 'package:prestige_pos/service/shared_service.dart';

class VenteService {
  final SharedService _sharedService;
  final  String baseUrl = '/ventes/';

  VenteService({required ApiClient apiClient})
    : _sharedService = SharedService(apiClient: apiClient);

  Future<ApiResponse<Vente>> find(String saleId) async {
    return await _sharedService.get<Vente>(
      endpoint: '$baseUrl$saleId',
      itemParserFromJson: (json) => Vente.fromJson(json),
    );
  }

  Future<ApiResponse<CreateResponse>> createVno(Vente vente) async {
   return await _sharedService.postData<CreateResponse>(
      endpoint: '${baseUrl}vno',
      body: vente.toJson(),
      itemParserFromJson: (json) => CreateResponse.fromJson(json),
    );

  }

  Future<ApiResponse<CreateResponse>> addItem(AddVenteItem item) async {
    return await _sharedService.postData<CreateResponse>(
      endpoint: '${baseUrl}add-item',
      body: item.toJson(),
      itemParserFromJson: (json) => CreateResponse.fromJson(json),
    );
  }

  Future<ApiResponse<CreateResponse>> removeItem(String itemId) async {
    return await _sharedService.deleteData<CreateResponse>(
      endpoint:'${baseUrl}remove/vno/item/$itemId',
      itemParserFromJson: (json) => CreateResponse.fromJson(json),
    );
  }

  Future<ApiResponse<CreateResponse>> updateItem(AddVenteItem item) async {
    return await _sharedService.postData<CreateResponse>(
      endpoint: '${baseUrl}update/item/vno',
      body: item.toJson(),
      itemParserFromJson: (json) => CreateResponse.fromJson(json),
    );
  }

  Future<ApiResponse<CreateResponse>> addRemise(AddRemise item) async {
    return await _sharedService.postData<CreateResponse>(
      endpoint: '${baseUrl}add/remise',
      body: item.toJson(),
      itemParserFromJson: (json) => CreateResponse.fromJson(json),
    );
  }

  Future<ApiResponse<FinalyseResponse>> finalyseVno(
    ClotureVente clotureVente,
  ) async {
    return await _sharedService.postData<FinalyseResponse>(
      endpoint: '${baseUrl}cloturer-vno',
      body: clotureVente.toJson(),
      itemParserFromJson: (json) => FinalyseResponse.fromJson(json),
    );
  }
}
