import '../../core/network/api_client.dart';
import '../models/prix_resume_model.dart';
import '../models/marche_model.dart';

class PrixRepository {
  PrixRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();
  final ApiClient _api;

  Future<PrixResumeModel> resume(int cultureId, {int? marcheId}) async {
    final data = await _api.get(
      '/prix/$cultureId',
      query: marcheId != null ? {'marche_id': '$marcheId'} : null,
    );
    return PrixResumeModel.fromJson(data);
  }

  Future<List<MarcheModel>> marchesProches(int cultureId, {String? ville}) async {
    final data = await _api.get(
      '/prix/$cultureId/marches',
      query: ville != null ? {'ville': ville} : null,
    ) as List;
    return data.map((e) => MarcheModel.fromJson(e)).toList();
  }
}
