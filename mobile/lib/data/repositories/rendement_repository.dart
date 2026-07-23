import '../../core/network/api_client.dart';
import '../models/rendement_model.dart';

class RendementRepository {
  RendementRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();
  final ApiClient _api;

  Future<RendementPredictionModel> predire({
    required int cultureId,
    required double superficieHa,
    required String typeSol,
    required String saison,
    required String pluviometrie,
  }) async {
    final data = await _api.post('/rendement/predire', body: {
      'culture_id': cultureId,
      'superficie_ha': superficieHa,
      'type_sol': typeSol,
      'saison': saison,
      'pluviometrie': pluviometrie,
    });
    return RendementPredictionModel.fromJson(data);
  }

  Future<List<RendementPredictionModel>> historique({int? cultureId}) async {
    final data = await _api.get(
      '/rendement/historique',
      query: cultureId != null ? {'culture_id': '$cultureId'} : null,
    ) as List;
    return data.map((e) => RendementPredictionModel.fromJson(e)).toList();
  }
}
