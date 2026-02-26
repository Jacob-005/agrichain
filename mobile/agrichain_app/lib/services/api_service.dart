import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Standardised result wrapper for API calls.
class ApiResult<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResult.success(this.data) : error = null, success = true;

  ApiResult.failure(this.error) : data = null, success = false;
}

class ApiService {
  final bool useMock;
  final String baseUrl;
  String? _authToken;

  ApiService({
    this.useMock = false,
    this.baseUrl = 'http://10.17.25.144:8000/api/v1',
  });

  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ─── Helpers ──────────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> _get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        return ApiResult.success(jsonDecode(res.body));
      }
      return ApiResult.failure('HTTP ${res.statusCode}: ${res.body}');
    } on TimeoutException {
      return ApiResult.failure('Request timed out. AI is busy, please retry.');
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResult.success(jsonDecode(res.body));
      }
      return ApiResult.failure('HTTP ${res.statusCode}: ${res.body}');
    } on TimeoutException {
      return ApiResult.failure(
        'Request timed out. AI is thinking, please retry.',
      );
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // ─── Auth ─────────────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> sendOtp(String phone) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResult.success({'success': true, 'message': 'OTP sent'});
    }
    return _post('/auth/send-otp', {'phone': phone});
  }

  Future<ApiResult<Map<String, dynamic>>> verifyOtp(
    String phone,
    String otp,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResult.success({
        'success': true,
        'token': 'mock_jwt_token_123',
        'is_new_user': true,
      });
    }
    return _post('/auth/verify-otp', {'phone': phone, 'otp': otp});
  }

  // ─── Profile ──────────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> createProfile(
    Map<String, dynamic> data,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResult.success({
        'success': true,
        'user': {
          'id': 'user_001',
          'name': data['name'] ?? 'Demo Farmer',
          'phone': data['phone'] ?? '9876543210',
          'village': data['village'] ?? 'Nagpur',
          'district': data['district'] ?? 'Nagpur',
          'state': data['state'] ?? 'Maharashtra',
        },
      });
    }
    return _post('/user/profile', data);
  }

  Future<ApiResult<Map<String, dynamic>>> getProfile() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResult.success({
        'id': 'user_001',
        'name': 'Demo Farmer',
        'phone': '9876543210',
        'village': 'Nagpur',
        'district': 'Nagpur',
        'state': 'Maharashtra',
        'crops': ['wheat', 'rice'],
        'soil_type': 'alluvial',
      });
    }
    return _get('/user/profile');
  }

  // ─── Crops & Soil ─────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getCrops() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResult.success({
        'crops': [
          // Vegetables
          {
            'id': 'tomato',
            'name': 'Tomato',
            'name_hi': 'टमाटर',
            'icon': '🍅',
            'category': 'Vegetables',
          },
          {
            'id': 'onion',
            'name': 'Onion',
            'name_hi': 'प्याज',
            'icon': '🧅',
            'category': 'Vegetables',
          },
          {
            'id': 'potato',
            'name': 'Potato',
            'name_hi': 'आलू',
            'icon': '🥔',
            'category': 'Vegetables',
          },
          {
            'id': 'brinjal',
            'name': 'Brinjal',
            'name_hi': 'बैंगन',
            'icon': '🍆',
            'category': 'Vegetables',
          },
          {
            'id': 'cabbage',
            'name': 'Cabbage',
            'name_hi': 'पत्तागोभी',
            'icon': '🥬',
            'category': 'Vegetables',
          },
          {
            'id': 'chilli',
            'name': 'Green Chilli',
            'name_hi': 'हरी मिर्च',
            'icon': '🌶️',
            'category': 'Vegetables',
          },
          // Fruits
          {
            'id': 'mango',
            'name': 'Mango',
            'name_hi': 'आम',
            'icon': '🥭',
            'category': 'Fruits',
          },
          {
            'id': 'banana',
            'name': 'Banana',
            'name_hi': 'केला',
            'icon': '🍌',
            'category': 'Fruits',
          },
          {
            'id': 'grapes',
            'name': 'Grapes',
            'name_hi': 'अंगूर',
            'icon': '🍇',
            'category': 'Fruits',
          },
          {
            'id': 'orange',
            'name': 'Orange',
            'name_hi': 'संतरा',
            'icon': '🍊',
            'category': 'Fruits',
          },
          {
            'id': 'pomegranate',
            'name': 'Pomegranate',
            'name_hi': 'अनार',
            'icon': '🫐',
            'category': 'Fruits',
          },
          // Grains
          {
            'id': 'wheat',
            'name': 'Wheat',
            'name_hi': 'गेहूँ',
            'icon': '🌾',
            'category': 'Grains',
          },
          {
            'id': 'rice',
            'name': 'Rice',
            'name_hi': 'चावल',
            'icon': '🍚',
            'category': 'Grains',
          },
          {
            'id': 'maize',
            'name': 'Maize',
            'name_hi': 'मक्का',
            'icon': '🌽',
            'category': 'Grains',
          },
          {
            'id': 'bajra',
            'name': 'Bajra',
            'name_hi': 'बाजरा',
            'icon': '🌿',
            'category': 'Grains',
          },
          {
            'id': 'jowar',
            'name': 'Jowar',
            'name_hi': 'ज्वार',
            'icon': '🪴',
            'category': 'Grains',
          },
          // Pulses
          {
            'id': 'chickpea',
            'name': 'Chickpea',
            'name_hi': 'चना',
            'icon': '🫘',
            'category': 'Pulses',
          },
          {
            'id': 'lentil',
            'name': 'Lentil',
            'name_hi': 'मसूर',
            'icon': '🥣',
            'category': 'Pulses',
          },
          {
            'id': 'moong',
            'name': 'Moong Dal',
            'name_hi': 'मूँग',
            'icon': '🌱',
            'category': 'Pulses',
          },
          {
            'id': 'tur',
            'name': 'Tur/Arhar',
            'name_hi': 'तूर/अरहर',
            'icon': '🥜',
            'category': 'Pulses',
          },
          // Spices
          {
            'id': 'turmeric',
            'name': 'Turmeric',
            'name_hi': 'हल्दी',
            'icon': '🟡',
            'category': 'Spices',
          },
          {
            'id': 'ginger',
            'name': 'Ginger',
            'name_hi': 'अदरक',
            'icon': '🫚',
            'category': 'Spices',
          },
          {
            'id': 'garlic',
            'name': 'Garlic',
            'name_hi': 'लहसुन',
            'icon': '🧄',
            'category': 'Spices',
          },
          {
            'id': 'coriander',
            'name': 'Coriander',
            'name_hi': 'धनिया',
            'icon': '🌿',
            'category': 'Spices',
          },
          // Cash Crops
          {
            'id': 'cotton',
            'name': 'Cotton',
            'name_hi': 'कपास',
            'icon': '🏵️',
            'category': 'Cash Crops',
          },
          {
            'id': 'sugarcane',
            'name': 'Sugarcane',
            'name_hi': 'गन्ना',
            'icon': '🎋',
            'category': 'Cash Crops',
          },
          {
            'id': 'soybean',
            'name': 'Soybean',
            'name_hi': 'सोयाबीन',
            'icon': '🫛',
            'category': 'Cash Crops',
          },
          {
            'id': 'tobacco',
            'name': 'Tobacco',
            'name_hi': 'तम्बाकू',
            'icon': '🍃',
            'category': 'Cash Crops',
          },
          // Medicinal
          {
            'id': 'aloe_vera',
            'name': 'Aloe Vera',
            'name_hi': 'एलोवेरा',
            'icon': '🌵',
            'category': 'Medicinal',
          },
          {
            'id': 'ashwagandha',
            'name': 'Ashwagandha',
            'name_hi': 'अश्वगंधा',
            'icon': '🪻',
            'category': 'Medicinal',
          },
          {
            'id': 'tulsi',
            'name': 'Tulsi',
            'name_hi': 'तुलसी',
            'icon': '☘️',
            'category': 'Medicinal',
          },
        ],
      });
    }
    return _get('/crops');
  }

  Future<ApiResult<Map<String, dynamic>>> getSoilTypes() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResult.success({
        'soil_types': [
          {
            'id': 'alluvial',
            'name': 'Alluvial',
            'name_hi': 'जलोढ़',
            'color_hex': '#C8A96E',
            'description': 'Found near river banks, very fertile',
            'description_hi': 'नदी किनारे पाई जाती है, बहुत उपजाऊ',
            'suitable_crops': ['Wheat', 'Rice', 'Sugarcane'],
          },
          {
            'id': 'black',
            'name': 'Black Soil',
            'name_hi': 'काली मिट्टी',
            'color_hex': '#3E2723',
            'description': 'Retains moisture, great for cotton',
            'description_hi': 'नमी रखती है, कपास के लिए बढ़िया',
            'suitable_crops': ['Cotton', 'Soybean', 'Jowar'],
          },
          {
            'id': 'red',
            'name': 'Red Soil',
            'name_hi': 'लाल मिट्टी',
            'color_hex': '#BF360C',
            'description': 'Rich in iron, needs fertilization',
            'description_hi': 'लोहे से भरपूर, उर्वरक की जरूरत',
            'suitable_crops': ['Groundnut', 'Potato', 'Maize'],
          },
          {
            'id': 'laterite',
            'name': 'Laterite',
            'name_hi': 'लैटेराइट',
            'color_hex': '#E65100',
            'description': 'Found in heavy rainfall areas',
            'description_hi': 'भारी वर्षा वाले क्षेत्र में पाई जाती है',
            'suitable_crops': ['Tea', 'Coffee', 'Cashew'],
          },
          {
            'id': 'sandy',
            'name': 'Sandy',
            'name_hi': 'रेतीली',
            'color_hex': '#F9A825',
            'description': 'Quick drainage, needs frequent watering',
            'description_hi': 'जल्दी सूखती है, बार-बार पानी चाहिए',
            'suitable_crops': ['Bajra', 'Moong', 'Watermelon'],
          },
          {
            'id': 'clayey',
            'name': 'Clayey',
            'name_hi': 'चिकनी',
            'color_hex': '#795548',
            'description': 'Heavy and sticky when wet, holds nutrients',
            'description_hi': 'भारी और चिपचिपी, पोषक तत्व रखती है',
            'suitable_crops': ['Rice', 'Wheat', 'Lentil'],
          },
        ],
      });
    }
    return _get('/soil-types');
  }

  Future<ApiResult<Map<String, dynamic>>> addUserCrops(
    List<String> cropIds,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResult.success({
        'success': true,
        'message': 'Crops saved',
        'crops': cropIds,
      });
    }
    return _post('/profile/crops', {'crop_ids': cropIds});
  }

  // ─── Harvest Score ────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getHarvestScore(String crop) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResult.success({
        'crop': crop,
        'overall_score': 78,
        'weather_score': 85,
        'soil_score': 72,
        'market_score': 76,
        'recommendation': 'Good time to harvest. Market prices are favourable.',
        'recommendation_hi': 'फसल काटने का अच्छा समय है। बाजार भाव अनुकूल हैं।',
        'status': 'good',
        'explanation':
            'Weather conditions are favorable with no rain expected for 5 days. '
            'Soil moisture is at optimal level (72%). '
            'Market prices at nearby mandis are 12% above average. '
            'Harvesting now will maximize your returns before prices dip next week.',
        'explanation_hi':
            'मौसम अनुकूल है, 5 दिनों तक बारिश की संभावना नहीं। '
            'मिट्टी की नमी सही स्तर (72%) पर है। '
            'नजदीकी मंडियों में भाव औसत से 12% ऊपर हैं। '
            'अभी कटाई करने पर अगले हफ्ते भाव गिरने से पहले अधिकतम लाभ मिलेगा।',
      });
    }
    return _post('/harvest/score', {'crop': crop});
  }

  // ─── Market Comparison ────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getMarketComparison(
    String crop,
    double volumeKg,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      // CRITICAL: Rank 1 has LOWER price/kg but HIGHEST pocket_cash
      final wardhaRevenue = volumeKg * 15;
      final wardhaFuel = 192.0;
      final wardhaSpoilage = volumeKg * 0.02 * 15; // 2% spoilage
      final wardhaPocket = wardhaRevenue - wardhaFuel - wardhaSpoilage;

      final amravatiRevenue = volumeKg * 22;
      final amravatiFuel = 2400.0;
      final amravatiSpoilage = volumeKg * 0.12 * 22; // 12% spoilage
      final amravatiPocket = amravatiRevenue - amravatiFuel - amravatiSpoilage;

      final nagpurRevenue = volumeKg * 18;
      final nagpurFuel = 720.0;
      final nagpurSpoilage = volumeKg * 0.08 * 18; // 8% spoilage
      final nagpurPocket = nagpurRevenue - nagpurFuel - nagpurSpoilage;

      return ApiResult.success({
        'crop': crop,
        'volume_kg': volumeKg,
        'mandis': [
          {
            'rank': 1,
            'name': 'Wardha Mandi',
            'distance_km': 12,
            'price_per_kg': 15,
            'fuel_cost': wardhaFuel,
            'spoilage_loss': wardhaSpoilage,
            'spoilage_pct': 2,
            'pocket_cash': wardhaPocket,
            'risk_level': 'low',
            'demand': 'high',
            'explanation':
                'Closest mandi with minimal transport cost (₹${wardhaFuel.toStringAsFixed(0)}) '
                'and only 2% spoilage. Lower per-kg price is offset by savings.',
          },
          {
            'rank': 2,
            'name': 'Amravati Market',
            'distance_km': 150,
            'price_per_kg': 22,
            'fuel_cost': amravatiFuel,
            'spoilage_loss': amravatiSpoilage,
            'spoilage_pct': 12,
            'pocket_cash': amravatiPocket,
            'risk_level': 'high',
            'demand': 'medium',
            'explanation':
                'Higher price per kg but 150km distance causes ₹${amravatiFuel.toStringAsFixed(0)} fuel '
                'and 12% spoilage loss. Net return is lower despite better price.',
          },
          {
            'rank': 3,
            'name': 'Nagpur APMC',
            'distance_km': 45,
            'price_per_kg': 18,
            'fuel_cost': nagpurFuel,
            'spoilage_loss': nagpurSpoilage,
            'spoilage_pct': 8,
            'pocket_cash': nagpurPocket,
            'risk_level': 'medium',
            'demand': 'low',
            'explanation':
                'Medium distance but low demand today. 8% spoilage risk '
                'and moderate transport costs reduce your net take-home.',
          },
        ],
        'best_option': 'Wardha Mandi',
      });
    }
    return _post('/market/compare', {'crop': crop, 'volume_kg': volumeKg});
  }

  // ─── Spoilage ─────────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getSpoilageCheck(
    String crop,
    String storage,
    double hours,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResult.success({
        'crop': crop,
        'storage_type': storage,
        'hours_since_harvest': hours,
        'spoilage_percentage': (hours / 100 * 15).clamp(0, 100),
        'remaining_hours': (72 - hours).clamp(0, 72),
        'status': hours < 24
            ? 'good'
            : hours < 48
            ? 'caution'
            : 'danger',
        'tip':
            'Move to cold storage within 24 hours to reduce spoilage by 60%.',
        'tip_hi':
            '24 घंटे के भीतर कोल्ड स्टोरेज में ले जाएं ताकि खराबी 60% कम हो।',
      });
    }
    return _get('/spoilage?crop=$crop&storage=$storage&hours=$hours');
  }

  Future<ApiResult<Map<String, dynamic>>> getSpoilageEstimate(
    String crop,
    String storageMethod,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      final hours = switch (storageMethod) {
        'cold_storage' => 168.0,
        'plastic_crates' => 72.0,
        'jute_bags' => 48.0,
        _ => 36.0, // open_floor
      };
      final initial = hours;
      return ApiResult.success({
        'crop': crop,
        'remaining_hours': hours,
        'initial_hours': initial,
        'risk_level': hours > 72
            ? 'low'
            : hours > 36
            ? 'medium'
            : 'high',
        'has_weather_alert': false,
        'storage_method': switch (storageMethod) {
          'cold_storage' => 'Cold Storage',
          'plastic_crates' => 'Plastic Crates',
          'jute_bags' => 'Jute Bags',
          _ => 'Open Floor',
        },
        'temperature': 32,
        'explanation':
            'Based on current temperature (32°C) and your storage method, '
            'your $crop has approximately ${hours.toStringAsFixed(0)} hours '
            'before significant spoilage begins. Selling within this window '
            'maximizes your returns.',
      });
    }
    return _post('/spoilage/check', {
      'crop': crop,
      'storage_method': storageMethod,
      'hours_since_harvest': 0,
    });
  }

  // ─── Preservation ─────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getPreservationOptions(
    String crop,
    String currentStorage,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResult.success({
        'crop': crop,
        'current_storage': currentStorage,
        'options': [
          {
            'method': 'Cold Storage',
            'method_hi': 'कोल्ड स्टोरेज',
            'icon': '❄️',
            'extends_life_hours': 168,
            'cost_per_kg': 2.5,
            'availability': 'Available at 3km',
          },
          {
            'method': 'Drying',
            'method_hi': 'सुखाना',
            'icon': '☀️',
            'extends_life_hours': 720,
            'cost_per_kg': 1.0,
            'availability': 'Can do at home',
          },
          {
            'method': 'Vacuum Packing',
            'method_hi': 'वैक्यूम पैकिंग',
            'icon': '📦',
            'extends_life_hours': 360,
            'cost_per_kg': 5.0,
            'availability': 'Available at 15km',
          },
        ],
      });
    }
    return _get('/preservation?crop=$crop&current_storage=$currentStorage');
  }

  Future<ApiResult<Map<String, dynamic>>> getPreservationMethods(
    String crop,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResult.success({
        'crop': crop,
        'methods': [
          {
            'level': 1,
            'name': 'Jute Bag Layering',
            'icon': '👜',
            'cost_rupees': 0,
            'extra_days': 2,
            'saves_rupees': 600,
            'instructions':
                '1. Line jute bags with newspaper\n'
                '2. Layer tomatoes in single rows\n'
                '3. Place in shade with good air flow\n'
                '4. Keep away from direct sunlight',
            'explanation':
                'Free method using materials you already have. '
                'Adds 2 days of shelf life by improving air circulation.',
          },
          {
            'level': 2,
            'name': 'Plastic Crate Storage',
            'icon': '📦',
            'cost_rupees': 200,
            'extra_days': 4,
            'saves_rupees': 1400,
            'instructions':
                '1. Buy or rent plastic crates (₹50-80 each)\n'
                '2. Line bottom with newspaper\n'
                '3. Stack tomatoes max 3 layers deep\n'
                '4. Store in covered, ventilated area\n'
                '5. Check daily and remove damaged ones',
            'explanation':
                'Small investment for big returns. '
                'Crates prevent crushing and allow air flow.',
          },
          {
            'level': 3,
            'name': 'Evaporative Cooling Bin',
            'icon': '❄️',
            'cost_rupees': 500,
            'extra_days': 7,
            'saves_rupees': 2800,
            'instructions':
                '1. Get two clay pots (one smaller inside larger)\n'
                '2. Fill gap between pots with wet sand\n'
                '3. Place tomatoes in inner pot\n'
                '4. Cover with wet cloth\n'
                '5. Keep sand moist — add water twice daily\n'
                '6. Temperature drops 10-15°C naturally',
            'explanation':
                'Traditional "Zeer Pot" method. Best value — '
                'spend ₹500 to save ₹2,800 in potential rot loss.',
          },
        ],
      });
    }
    return _post('/preservation/options', {'crop': crop});
  }

  // ─── Chat ─────────────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> sendChatMessage(
    String message,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ApiResult.success({
        'reply':
            'Based on current conditions, your wheat crop is in good health. Consider harvesting within the next 5 days for optimal prices.',
        'reply_hi':
            'वर्तमान स्थितियों के आधार पर, आपकी गेहूं की फसल अच्छी स्थिति में है। सर्वोत्तम कीमतों के लिए अगले 5 दिनों में कटाई करने पर विचार करें।',
      });
    }
    return _post('/chat/', {'message': message});
  }

  // ─── Weather ──────────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getWeather(
    double lat,
    double lng,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResult.success({
        'location': 'Nagpur, Maharashtra',
        'temperature': 32,
        'humidity': 65,
        'condition': 'Partly Cloudy',
        'icon': '⛅',
        'forecast': [
          {'day': 'Today', 'high': 34, 'low': 22, 'condition': 'Sunny'},
          {'day': 'Tomorrow', 'high': 33, 'low': 21, 'condition': 'Cloudy'},
          {'day': 'Day 3', 'high': 30, 'low': 20, 'condition': 'Rain'},
        ],
      });
    }
    return _get('/weather?lat=$lat&lng=$lng');
  }

  // ─── Advice History ───────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getAdviceHistory() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResult.success({
        'history': [
          {
            'id': '1',
            'type': 'harvest',
            'crop': 'Wheat',
            'advice': 'Harvest in 3 days for best price.',
            'date': '2026-02-25',
            'status': 'followed',
          },
          {
            'id': '2',
            'type': 'market',
            'crop': 'Tomato',
            'advice': 'Sell at Nagpur APMC — price peak expected.',
            'date': '2026-02-24',
            'status': 'pending',
          },
          {
            'id': '3',
            'type': 'preservation',
            'crop': 'Onion',
            'advice': 'Move to cold storage immediately.',
            'date': '2026-02-23',
            'status': 'ignored',
          },
        ],
      });
    }
    return _get('/advice-history');
  }

  // ─── Notifications ────────────────────────────────────────────────────

  Future<ApiResult<Map<String, dynamic>>> getNotifications() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResult.success({
        'notifications': [
          {
            'id': '1',
            'title': 'Price Alert',
            'body': 'Wheat price up 12% at Nagpur APMC',
            'type': 'market',
            'read': false,
            'timestamp': '2026-02-26T10:30:00',
          },
          {
            'id': '2',
            'title': 'Spoilage Warning',
            'body': 'Tomatoes reaching critical spoilage in 6 hours',
            'type': 'spoilage',
            'read': false,
            'timestamp': '2026-02-26T09:15:00',
          },
          {
            'id': '3',
            'title': 'Weather Alert',
            'body': 'Heavy rain expected tomorrow — plan harvest today',
            'type': 'weather',
            'read': true,
            'timestamp': '2026-02-25T18:00:00',
          },
        ],
      });
    }
    return _get('/notifications');
  }
}
