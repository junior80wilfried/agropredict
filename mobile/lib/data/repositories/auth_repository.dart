import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();
  final ApiClient _api;

  Future<UserModel> inscription({
    required String nom,
    required String email,
    required String motDePasse,
    String? telephone,
    String? ville,
    String? region,
    int? agriculteurDepuis,
  }) async {
    final data = await _api.post('/auth/inscription', auth: false, body: {
      'nom': nom,
      'email': email,
      'mot_de_passe': motDePasse,
      if (telephone != null) 'telephone': telephone,
      if (ville != null) 'ville': ville,
      if (region != null) 'region': region,
      if (agriculteurDepuis != null) 'agriculteur_depuis': agriculteurDepuis,
    });
    await SecureStorage.instance.saveToken(data['token']);
    return UserModel.fromJson(data['utilisateur']);
  }

  Future<UserModel> connexion({required String email, required String motDePasse}) async {
    final data = await _api.post('/auth/connexion', auth: false, body: {
      'email': email,
      'mot_de_passe': motDePasse,
    });
    await SecureStorage.instance.saveToken(data['token']);
    return UserModel.fromJson(data['utilisateur']);
  }

  Future<UserModel?> utilisateurConnecte() async {
    final token = await SecureStorage.instance.readToken();
    if (token == null) return null;
    try {
      final data = await _api.get('/auth/moi');
      return UserModel.fromJson(data);
    } catch (_) {
      await SecureStorage.instance.clearToken();
      return null;
    }
  }

  Future<void> deconnexion() => SecureStorage.instance.clearToken();
}
