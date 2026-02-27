import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const _keyToken = 'auth_token';
  static const _keyLanguage = 'language';
  static const _keyOnboarding = 'onboarding_complete';
  static const _keyUserName = 'user_name';
  static const _keyUserPhone = 'user_phone';
  static const _keyDistrict = 'user_district';
  static const _keyLat = 'user_lat';
  static const _keyLng = 'user_lng';
  static const _keySelectedCrops = 'selected_crops';
  static const _keySoilType = 'soil_type';

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

  // ─── User Profile ──────────────────────────────────────────────────────

  Future<void> saveUserProfile({
    required String name,
    required String phone,
    required String district,
    required double lat,
    required double lng,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserPhone, phone);
    await prefs.setString(_keyDistrict, district);
    await prefs.setDouble(_keyLat, lat);
    await prefs.setDouble(_keyLng, lng);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await _prefs;
    final name = prefs.getString(_keyUserName);
    if (name == null) return null;
    return {
      'name': name,
      'phone': prefs.getString(_keyUserPhone) ?? '',
      'district': prefs.getString(_keyDistrict) ?? 'Nagpur',
      'lat': prefs.getDouble(_keyLat) ?? 21.1458,
      'lng': prefs.getDouble(_keyLng) ?? 79.0882,
    };
  }

  // ─── Selected Crops ────────────────────────────────────────────────────

  Future<void> saveSelectedCrops(List<Map<String, String>> crops) async {
    final prefs = await _prefs;
    await prefs.setString(_keySelectedCrops, jsonEncode(crops));
  }

  Future<List<Map<String, String>>?> getSelectedCrops() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keySelectedCrops);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  // ─── Soil Type ─────────────────────────────────────────────────────────

  Future<void> saveSoilType(String soilType) async {
    final prefs = await _prefs;
    await prefs.setString(_keySoilType, soilType);
  }

  Future<String?> getSoilType() async {
    final prefs = await _prefs;
    return prefs.getString(_keySoilType);
  }

  // ─── Clear All ─────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
