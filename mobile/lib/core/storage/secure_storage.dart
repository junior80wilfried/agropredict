import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé du token JWT (Keychain sur iOS, Keystore sur Android).
class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'agrosense_token';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
