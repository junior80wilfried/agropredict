/// Configuration de l'API backend Flask.
///
/// ⚠️ À adapter selon l'environnement d'exécution :
///  - Émulateur Android : http://10.0.2.2:5000
///  - Simulateur iOS / Flutter Web / bureau : http://localhost:5000
///  - Appareil physique : http://<IP_DE_VOTRE_MACHINE>:5000
///  - Production : URL du serveur déployé (https://...)
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  static const String apiPrefix = '/api';

  static Uri uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$apiPrefix$path').replace(queryParameters: query);
  }
}
