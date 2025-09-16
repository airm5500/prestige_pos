import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/vente/search_produit_result.dart';
import 'package:prestige_pos/service/shared_service.dart';

class ProduitService {
  final SharedService _sharedService;

  ProduitService({required ApiClient apiClient})
    : _sharedService = SharedService(apiClient: apiClient);

  Future<ApiResponse<List<SearchProduitResult>>> fetchAll(
    String search,
    int? pageSize,
  ) async {
    final Map<String, String> queryParameters = {};
    if (search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (pageSize != null) {
      queryParameters['size'] = pageSize.toString();
    }

    return await _sharedService.getData<SearchProduitResult>(
      endpoint: '/produits/search',
      queryParameters: queryParameters,
      itemParserFromJson: (json) => SearchProduitResult.fromJson(json),
    );
  }
}
