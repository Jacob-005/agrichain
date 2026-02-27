import 'package:flutter/material.dart';
import '../app/theme.dart';

class LocationPicker {
  // Predefined districts with coordinates (common farming regions)
  static const List<Map<String, dynamic>> districts = [
    {"name": "Nagpur", "state": "Maharashtra", "lat": 21.1458, "lng": 79.0882},
    {"name": "Wardha", "state": "Maharashtra", "lat": 20.7453, "lng": 78.6022},
    {
      "name": "Amravati",
      "state": "Maharashtra",
      "lat": 20.9374,
      "lng": 77.7796,
    },
    {
      "name": "Yavatmal",
      "state": "Maharashtra",
      "lat": 20.3899,
      "lng": 78.1307,
    },
    {
      "name": "Chandrapur",
      "state": "Maharashtra",
      "lat": 19.9615,
      "lng": 79.2961,
    },
    {"name": "Akola", "state": "Maharashtra", "lat": 20.7002, "lng": 77.0082},
    {"name": "Nashik", "state": "Maharashtra", "lat": 19.9975, "lng": 73.7898},
    {"name": "Pune", "state": "Maharashtra", "lat": 18.5204, "lng": 73.8567},
    {
      "name": "Aurangabad",
      "state": "Maharashtra",
      "lat": 19.8762,
      "lng": 75.3433,
    },
    {"name": "Latur", "state": "Maharashtra", "lat": 18.3968, "lng": 76.5604},
    {"name": "Solapur", "state": "Maharashtra", "lat": 17.6599, "lng": 75.9064},
    {
      "name": "Kolhapur",
      "state": "Maharashtra",
      "lat": 16.7050,
      "lng": 74.2433,
    },
    {
      "name": "Indore",
      "state": "Madhya Pradesh",
      "lat": 22.7196,
      "lng": 75.8577,
    },
    {
      "name": "Bhopal",
      "state": "Madhya Pradesh",
      "lat": 23.2599,
      "lng": 77.4126,
    },
    {
      "name": "Jabalpur",
      "state": "Madhya Pradesh",
      "lat": 23.1815,
      "lng": 79.9864,
    },
    {"name": "Raipur", "state": "Chhattisgarh", "lat": 21.2514, "lng": 81.6296},
    {"name": "Hyderabad", "state": "Telangana", "lat": 17.3850, "lng": 78.4867},
    {"name": "Jaipur", "state": "Rajasthan", "lat": 26.9124, "lng": 75.7873},
    {
      "name": "Lucknow",
      "state": "Uttar Pradesh",
      "lat": 26.8467,
      "lng": 80.9462,
    },
    {"name": "Patna", "state": "Bihar", "lat": 25.6093, "lng": 85.1376},
  ];

  static void show(
    BuildContext context, {
    required Function(String district, double lat, double lng)
    onLocationSelected,
  }) {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(districts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── HANDLE BAR ──
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── TITLE ──
                      const Text(
                        "📍 Change Location",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Select your district for accurate recommendations",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),

                      // ── GPS BUTTON ──
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Default to Nagpur GPS for now
                            // In production, use geolocator package
                            Navigator.pop(context);
                            onLocationSelected("Nagpur", 21.1458, 79.0882);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text("📍 Location detected: Nagpur"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.my_location,
                            color: AgriChainTheme.primaryGreen,
                          ),
                          label: const Text(
                            "Use Current GPS Location",
                            style: TextStyle(
                              color: AgriChainTheme.primaryGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: AgriChainTheme.primaryGreen,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── SEARCH BAR ──
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search district...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            filtered = districts
                                .where(
                                  (d) =>
                                      d["name"]
                                          .toString()
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      d["state"]
                                          .toString()
                                          .toLowerCase()
                                          .contains(query.toLowerCase()),
                                )
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // ── DISTRICT LIST ──
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final d = filtered[index];
                            return ListTile(
                              leading: const Text(
                                "📍",
                                style: TextStyle(fontSize: 20),
                              ),
                              title: Text(
                                d["name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                d["state"],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                onLocationSelected(
                                  d["name"],
                                  d["lat"],
                                  d["lng"],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
