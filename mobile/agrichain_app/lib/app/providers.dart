import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// ── API Configuration ─────────────────────────────────────────────────────
// Toggle this to switch between mock and real API
const bool useMockApi = false;

// Change this to J's IP address (from ipconfig on J's laptop)
// Use 10.0.2.2 for Android emulator → localhost
const String backendIp = '10.17.25.144';
const String apiBaseUrl = 'http://$backendIp:8000/api/v1';

// ---------------------------------------------------------------------------
// Service providers
// ---------------------------------------------------------------------------
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(useMock: useMockApi, baseUrl: apiBaseUrl);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// ---------------------------------------------------------------------------
// User state
// ---------------------------------------------------------------------------
class UserState {
  final String? authToken;
  final String? phone;
  final String? name;
  final String language;
  final bool isLoggedIn;

  const UserState({
    this.authToken,
    this.phone,
    this.name,
    this.language = 'en',
    this.isLoggedIn = false,
  });

  UserState copyWith({
    String? authToken,
    String? phone,
    String? name,
    String? language,
    bool? isLoggedIn,
  }) {
    return UserState(
      authToken: authToken ?? this.authToken,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      language: language ?? this.language,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class UserStateNotifier extends StateNotifier<UserState> {
  UserStateNotifier() : super(const UserState());

  void setToken(String token) =>
      state = state.copyWith(authToken: token, isLoggedIn: true);

  void setLanguage(String lang) => state = state.copyWith(language: lang);

  void setProfile({required String name, required String phone}) =>
      state = state.copyWith(name: name, phone: phone);

  void logout() => state = const UserState();
}

final userStateProvider = StateNotifierProvider<UserStateNotifier, UserState>((
  ref,
) {
  return UserStateNotifier();
});

// ---------------------------------------------------------------------------
// App navigation state
// ---------------------------------------------------------------------------
class AppState {
  final int currentNavIndex;

  const AppState({this.currentNavIndex = 0});

  AppState copyWith({int? currentNavIndex}) {
    return AppState(currentNavIndex: currentNavIndex ?? this.currentNavIndex);
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setNavIndex(int index) => state = state.copyWith(currentNavIndex: index);
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});
