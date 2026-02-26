import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyToken = 'auth_token';
  static const _keyLanguage = 'language';
  static const _keyOnboarding = 'onboarding_complete';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ─── Auth Token ─────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_keyToken);
  }

  // ─── Language ─────────────────────────────────────────────────────────

  Future<void> saveLanguage(String language) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLanguage, language);
  }

  Future<String?> getLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_keyLanguage);
  }

  // ─── Onboarding ───────────────────────────────────────────────────────

  Future<void> saveOnboardingComplete(bool complete) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboarding, complete);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboarding) ?? false;
  }
}
