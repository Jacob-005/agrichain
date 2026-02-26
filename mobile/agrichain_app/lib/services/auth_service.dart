import '../services/storage_service.dart';

class AuthService {
  final StorageService _storage;

  AuthService(this._storage);

  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveSession(String token) async {
    await _storage.saveToken(token);
  }

  Future<void> logout() async {
    await _storage.clearToken();
  }
}
