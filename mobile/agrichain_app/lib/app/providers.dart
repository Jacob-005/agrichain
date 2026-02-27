import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// ── API Configuration ─────────────────────────────────────────────────────
// Toggle this to switch between mock and real API
// true = mock data for backend-dependent features (auth, crops, harvest, market, etc.)
// External APIs (OpenWeatherMap, Soil screen, Nearest DC) are NOT affected by this flag.
const bool useMockApi = true;

// Using ADB reverse tunnel: phone:8001 → laptop:8000
// Run: adb reverse tcp:8001 tcp:8000
// For Wi-Fi (same network): use your laptop IP instead of localhost
const String backendIp = 'localhost';
const int backendPort = 8001;
const String apiBaseUrl = 'http://$backendIp:$backendPort/api/v1';

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

// ---------------------------------------------------------------------------
// Location state
// ---------------------------------------------------------------------------
class LocationState {
  final String district;
  final double lat;
  final double lng;

  const LocationState({
    this.district = 'Nagpur',
    this.lat = 21.1458,
    this.lng = 79.0882,
  });

  LocationState copyWith({String? district, double? lat, double? lng}) {
    return LocationState(
      district: district ?? this.district,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  void update(String district, double lat, double lng) {
    state = state.copyWith(district: district, lat: lat, lng: lng);
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);

// ---------------------------------------------------------------------------
// Selected crops state
// ---------------------------------------------------------------------------
class SelectedCropsNotifier extends StateNotifier<List<Map<String, String>>> {
  SelectedCropsNotifier()
    : super(const [
        {'id': 'tomato', 'name': 'Tomato', 'icon': '🍅'},
        {'id': 'onion', 'name': 'Onion', 'icon': '🧅'},
        {'id': 'potato', 'name': 'Potato', 'icon': '🥔'},
        {'id': 'wheat', 'name': 'Wheat', 'icon': '🌾'},
        {'id': 'rice', 'name': 'Rice', 'icon': '🍚'},
      ]);

  void setCrops(List<Map<String, String>> crops) => state = crops;
}

final selectedCropsProvider =
    StateNotifierProvider<SelectedCropsNotifier, List<Map<String, String>>>((
      ref,
    ) {
      return SelectedCropsNotifier();
    });

// ---------------------------------------------------------------------------
// Soil type state
// ---------------------------------------------------------------------------
final soilTypeProvider = StateProvider<String>((ref) => 'black_cotton');
