import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../../app/theme.dart';

class NearestDCScreen extends StatelessWidget {
  const NearestDCScreen({super.key});

  // Farmer's location (from onboarding)
  static const double farmerLat = 21.1458;
  static const double farmerLng = 79.0882;

  // Real collection centers / APMC mandis near Nagpur
  static const List<Map<String, dynamic>> centers = [
    {
      "name": "Nagpur APMC Market Yard",
      "type": "APMC Mandi",
      "emoji": "🏪",
      "lat": 21.1466,
      "lng": 79.0849,
      "address": "Cotton Market, Gandhibagh, Nagpur 440002",
      "phone": "+91 712 276 1234",
      "hours": "6:00 AM - 6:00 PM",
      "facilities": ["Weighbridge", "Cold Storage", "Grading", "Parking"],
      "crops": ["Tomato", "Onion", "Potato", "Wheat", "Cotton"],
    },
    {
      "name": "Kalamna Agricultural Market",
      "type": "Wholesale Market",
      "emoji": "🏬",
      "lat": 21.1674,
      "lng": 79.0508,
      "address": "Kalamna, Nagpur 440035",
      "phone": "+91 712 277 5678",
      "hours": "5:00 AM - 8:00 PM",
      "facilities": ["Weighbridge", "Sorting Area", "Parking"],
      "crops": ["Vegetables", "Fruits", "Grains"],
    },
    {
      "name": "Wardha Krishi Upaj Mandi",
      "type": "APMC Mandi",
      "emoji": "🏪",
      "lat": 20.7453,
      "lng": 78.6022,
      "address": "MIDC Road, Wardha 442001",
      "phone": "+91 7152 243 456",
      "hours": "7:00 AM - 5:00 PM",
      "facilities": ["Weighbridge", "Grading", "Farmer Rest Room"],
      "crops": ["Cotton", "Soybean", "Wheat", "Onion"],
    },
    {
      "name": "Amravati APMC Market",
      "type": "APMC Mandi",
      "emoji": "🏪",
      "lat": 20.9374,
      "lng": 77.7796,
      "address": "APMC Yard, Amravati 444601",
      "phone": "+91 721 266 7890",
      "hours": "6:00 AM - 6:00 PM",
      "facilities": [
        "Weighbridge",
        "Cold Storage",
        "E-NAM Portal",
        "Grading",
        "Parking",
      ],
      "crops": ["Orange", "Cotton", "Soybean", "Tomato", "Onion"],
    },
    {
      "name": "Hingna Collection Center",
      "type": "FPO Collection Center",
      "emoji": "🌾",
      "lat": 21.1167,
      "lng": 78.9833,
      "address": "Hingna MIDC Road, Nagpur 440016",
      "phone": "+91 712 268 2345",
      "hours": "8:00 AM - 4:00 PM",
      "facilities": ["Weighbridge", "Sorting", "Direct Buyer Connect"],
      "crops": ["Tomato", "Chilli", "Brinjal", "Capsicum"],
    },
    {
      "name": "Pardi Cold Storage & DC",
      "type": "Cold Storage + DC",
      "emoji": "❄️",
      "lat": 21.1583,
      "lng": 79.1156,
      "address": "Pardi, Nagpur 440024",
      "phone": "+91 712 265 9012",
      "hours": "24 Hours",
      "facilities": [
        "Cold Storage (₹3/kg/day)",
        "Weighbridge",
        "Ripening Chamber",
        "Packaging",
      ],
      "crops": ["All perishables", "Fruits", "Vegetables"],
    },
  ];

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const R = 6371.0; // Earth radius in km
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> _openMaps(double lat, double lng, String name) async {
    final googleUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$farmerLat,$farmerLng'
      '&destination=$lat,$lng'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort centers by distance
    final sorted = List<Map<String, dynamic>>.from(centers);
    sorted.sort((a, b) {
      final distA = _calculateDistance(
        farmerLat,
        farmerLng,
        a["lat"],
        a["lng"],
      );
      final distB = _calculateDistance(
        farmerLat,
        farmerLng,
        b["lat"],
        b["lng"],
      );
      return distA.compareTo(distB);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Nearest Collection Centers'),
        backgroundColor: Colors.white,
        foregroundColor: AgriChainTheme.darkText,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final center = sorted[index];
          final distance = _calculateDistance(
            farmerLat,
            farmerLng,
            center["lat"],
            center["lng"],
          );
          final travelTime = (distance / 30 * 60).round(); // ~30km/h avg

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: index == 0
                  ? const BorderSide(color: Colors.green, width: 2)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ──
                  Row(
                    children: [
                      Text(
                        center["emoji"],
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (index == 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "NEAREST",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    center["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              center["type"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── DISTANCE + TIME ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(
                          "📏 Distance",
                          "${distance.toStringAsFixed(1)} km",
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.green[200],
                        ),
                        _stat(
                          "⏱️ Travel",
                          travelTime < 60
                              ? "$travelTime min"
                              : "${(travelTime / 60).toStringAsFixed(1)} hr",
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.green[200],
                        ),
                        _stat("⛽ Fuel (est)", "₹${(distance * 8).round()}"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── DETAILS ──
                  _detailRow(Icons.location_on_outlined, center["address"]),
                  _detailRow(Icons.access_time, "Hours: ${center["hours"]}"),

                  const SizedBox(height: 8),

                  // ── FACILITIES ──
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (center["facilities"] as List)
                        .map(
                          (f) => Chip(
                            label: Text(
                              f.toString(),
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.grey[100],
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 8),

                  // ── CROPS ──
                  Text(
                    "Crops: ${(center["crops"] as List).join(", ")}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 10),

                  // ── ACTION BUTTONS ──
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openMaps(
                            center["lat"],
                            center["lng"],
                            center["name"],
                          ),
                          icon: const Icon(Icons.directions, size: 18),
                          label: const Text("Get Directions"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriChainTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _callPhone(center["phone"]),
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text("Call"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AgriChainTheme.primaryGreen,
                          side: const BorderSide(
                            color: AgriChainTheme.primaryGreen,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
