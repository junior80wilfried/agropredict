import '../../core/network/api_client.dart';
import '../models/culture_model.dart';
import '../models/recommandation_model.dart';

class CulturesRepository {
  CulturesRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();
  final ApiClient _api;

  Future<List<CultureModel>> lister() async {
    final data = await _api.get('/cultures') as List;
    return data.map((e) => CultureModel.fromJson(e)).toList();
  }

  Future<List<RecommandationModel>> recommandations({
    required String typeSol,
    required String saison,
  }) async {
    final data = await _api.get('/cultures/recommandations', query: {
      'type_sol': typeSol,
      'saison': saison,
    }) as List;
    return data.map((e) => RecommandationModel.fromJson(e)).toList();
  }
}
