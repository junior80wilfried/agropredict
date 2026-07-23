import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

/// Client HTTP centralisé : ajoute automatiquement le token JWT, encode/
/// décode le JSON, et convertit les erreurs serveur en [ApiException].
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await SecureStorage.instance.readToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body is Map<String, dynamic> ? body['erreur'] as String? : null;
    throw ApiException.fromStatus(response.statusCode, message);
  }

  Future<dynamic> get(String path, {Map<String, String>? query, bool auth = true}) async {
    try {
      final response = await _http.get(ApiConstants.uri(path, query), headers: await _headers(auth: auth));
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Impossible de contacter le serveur. Vérifiez votre connexion.');
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final response = await _http.post(
        ApiConstants.uri(path),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Impossible de contacter le serveur. Vérifiez votre connexion.');
    }
  }
}
