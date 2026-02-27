import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  int _age = 35;
  bool _gpsDetected = false;
  bool _manualMode = false;

  String? _selectedState;
  String? _selectedDistrict;
  String _detectedLocation = '';

  // Hardcoded state > district map for demo
  static const _stateDistricts = {
    'Maharashtra': ['Nagpur', 'Amravati', 'Wardha', 'Nashik', 'Pune'],
    'Madhya Pradesh': ['Indore', 'Bhopal', 'Dewas'],
    'Uttar Pradesh': ['Lucknow', 'Varanasi'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli'],
  };

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      (_gpsDetected || (_selectedState != null && _selectedDistrict != null));

  void _useGpsLocation() {
    setState(() {
      _gpsDetected = true;
      _manualMode = false;
      _detectedLocation = 'Nagpur, Maharashtra';
      _selectedState = 'Maharashtra';
      _selectedDistrict = 'Nagpur';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '📍 Location detected: Nagpur, Maharashtra',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: AgriChainTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _submitProfile() async {
    final name = _nameController.text.trim();
    final phone = ref.read(userStateProvider).phone ?? '9876543210';
    final district = _selectedDistrict ?? 'Nagpur';

    ref.read(userStateProvider.notifier).setProfile(name: name, phone: phone);

    // Persist to storage
    final storage = ref.read(storageServiceProvider);

    // Find lat/lng for the selected district
    double lat = 21.1458;
    double lng = 79.0882;
    for (final state in _stateDistricts.entries) {
      if (state.value.contains(district)) {
        // Use LocationPicker districts for coordinates
        break;
      }
    }
    // Simple lookup for known districts
    const districtCoords = {
      'Nagpur': [21.1458, 79.0882],
      'Amravati': [20.9374, 77.7796],
      'Wardha': [20.7453, 78.6022],
      'Nashik': [19.9975, 73.7898],
      'Pune': [18.5204, 73.8567],
      'Indore': [22.7196, 75.8577],
      'Bhopal': [23.2599, 77.4126],
      'Dewas': [22.9676, 76.0534],
      'Lucknow': [26.8467, 80.9462],
      'Varanasi': [25.3176, 82.9739],
      'Jaipur': [26.9124, 75.7873],
      'Jodhpur': [26.2389, 73.0243],
      'Udaipur': [24.5854, 73.7125],
      'Bangalore': [12.9716, 77.5946],
      'Mysore': [12.2958, 76.6394],
      'Hubli': [15.3647, 75.1240],
    };
    if (districtCoords.containsKey(district)) {
      lat = districtCoords[district]![0];
      lng = districtCoords[district]![1];
    }

    await storage.saveUserProfile(
      name: name,
      phone: phone,
      district: district,
      lat: lat,
      lng: lng,
    );

    // Update location provider
    ref.read(locationProvider.notifier).update(district, lat, lng);

    if (mounted) context.go('/crop-selection');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AgriChainTheme.darkText,
                      ),
                      onPressed: () => context.go('/otp'),
                    ),
                    const SizedBox(height: 12),

                    // ── Header ──
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AgriChainTheme.primaryGreen.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 28,
                        color: AgriChainTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tell Us About Yourself',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This helps us personalize your experience',
                      style: TextStyle(
                        fontSize: 16,
                        color: AgriChainTheme.greyText,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Name field ──
                    const Text(
                      'Your Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 18),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: Icon(
                          Icons.person,
                          color: AgriChainTheme.primaryGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Age picker ──
                    const Text(
                      'Your Age',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.agriculture,
                          color: AgriChainTheme.primaryGreen,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AgriChainTheme.primaryGreen,
                              inactiveTrackColor: AgriChainTheme.primaryGreen
                                  .withValues(alpha: 0.2),
                              thumbColor: AgriChainTheme.primaryGreen,
                              overlayColor: AgriChainTheme.primaryGreen
                                  .withValues(alpha: 0.1),
                              valueIndicatorColor: AgriChainTheme.primaryGreen,
                              showValueIndicator: ShowValueIndicator.always,
                            ),
                            child: Slider(
                              value: _age.toDouble(),
                              min: 18,
                              max: 80,
                              divisions: 62,
                              label: '$_age years',
                              onChanged: (v) =>
                                  setState(() => _age = v.round()),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AgriChainTheme.primaryGreen.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_age',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AgriChainTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Location ──
                    const Text(
                      'Your Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // GPS button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _useGpsLocation,
                        icon: const Icon(Icons.my_location, size: 24),
                        label: Text(
                          _gpsDetected
                              ? '📍 $_detectedLocation'
                              : '📍 Use GPS Location',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gpsDetected
                              ? AgriChainTheme.primaryGreen
                              : AgriChainTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Manual button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _manualMode = !_manualMode),
                        icon: const Icon(Icons.edit_location_alt, size: 24),
                        label: const Text(
                          '✏️ Enter Manually',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    // Manual entry dropdowns
                    if (_manualMode) ...[
                      const SizedBox(height: 20),

                      // State dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedState,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          prefixIcon: Icon(
                            Icons.flag,
                            color: AgriChainTheme.primaryGreen,
                          ),
                        ),
                        items: _stateDistricts.keys
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedState = val;
                            _selectedDistrict = null;
                            _gpsDetected = false;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // District dropdown
                      if (_selectedState != null)
                        DropdownButtonFormField<String>(
                              value: _selectedDistrict,
                              decoration: const InputDecoration(
                                labelText: 'District',
                                prefixIcon: Icon(
                                  Icons.map,
                                  color: AgriChainTheme.primaryGreen,
                                ),
                              ),
                              items: (_stateDistricts[_selectedState] ?? [])
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedDistrict = val),
                            )
                            .animate()
                            .fadeIn(duration: 200.ms)
                            .slideY(begin: 0.1, end: 0, duration: 200.ms),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Sticky bottom button ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isFormValid ? _submitProfile : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next →', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
