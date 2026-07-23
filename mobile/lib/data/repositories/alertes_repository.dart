import '../../core/network/api_client.dart';
import '../models/alerte_model.dart';

class AlertesRepository {
  AlertesRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();
  final ApiClient _api;

  Future<List<AlerteModel>> lister() async {
    final data = await _api.get('/alertes') as List;
    return data.map((e) => AlerteModel.fromJson(e)).toList();
  }
}
