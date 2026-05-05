import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'username';

  static Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<String?> getUsername() {
    return _storage.read(key: _usernameKey);
  }

  static Future<void> saveSession({
    required String token,
    required String username,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _usernameKey, value: username);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
}
