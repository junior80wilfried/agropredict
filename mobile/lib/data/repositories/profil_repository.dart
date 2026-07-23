import '../../core/network/api_client.dart';
import '../models/profil_model.dart';

class ProfilRepository {
  ProfilRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();
  final ApiClient _api;

  Future<ProfilModel> obtenirProfil() async {
    final data = await _api.get('/profil');
    return ProfilModel.fromJson(data);
  }

  Future<void> ajouterParcelle({
    required int cultureId,
    required double superficieHa,
    String typeSol = 'Argilo-limoneux',
    String statut = 'Planté',
  }) {
    return _api.post('/profil/parcelles', body: {
      'culture_id': cultureId,
      'superficie_ha': superficieHa,
      'type_sol': typeSol,
      'statut': statut,
    });
  }
}
