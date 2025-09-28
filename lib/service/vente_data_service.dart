import 'package:prestige_pos/auth/service/api_client.dart';
import 'package:prestige_pos/model/api_response.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/service/shared_service.dart';

class VenteDataService {
  final SharedService _sharedService;

  VenteDataService({required ApiClient apiClient})
    : _sharedService = SharedService(apiClient: apiClient);

  Future<ApiResponse<List<CreateResponse>>> fetchAll(String? search) async {
    final Map<String, String> queryParameters = {};
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    return await _sharedService.getData<CreateResponse>(
      endpoint: '/ventes/preventes',
      queryParameters: queryParameters,
      itemParserFromJson: (json) => CreateResponse.fromJson(json),
    );
  }
}
