import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../app/theme.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _current;
  List<dynamic>? _forecast;

  // Nagpur coordinates (farmer's default location)
  final double lat = 21.1458;
  final double lng = 79.0882;

  // ⚠️ Replace with your actual OpenWeatherMap API key
  final String apiKey = "ebd3c015cb17719a30cd179920063056";

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Current weather
      final currentUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?lat=$lat&lon=$lng&units=metric&appid=$apiKey',
      );
      final currentRes = await http
          .get(currentUrl)
          .timeout(const Duration(seconds: 10));

      // 5-day / 3-hour forecast (next 24h = 8 intervals)
      final forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast'
        '?lat=$lat&lon=$lng&units=metric&cnt=8&appid=$apiKey',
      );
      final forecastRes = await http
          .get(forecastUrl)
          .timeout(const Duration(seconds: 10));

      if (currentRes.statusCode == 200 && forecastRes.statusCode == 200) {
        setState(() {
          _current = json.decode(currentRes.body);
          _forecast = json.decode(forecastRes.body)['list'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Could not load weather data';
          _loading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        _error = 'Weather request timed out. Try again.';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Network error. Check your connection.';
        _loading = false;
      });
    }
  }

  String _weatherEmoji(String? main) {
    switch (main?.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'haze':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  Color _tempColor(double temp) {
    if (temp >= 40) return Colors.red;
    if (temp >= 35) return Colors.orange;
    if (temp >= 25) return Colors.amber;
    if (temp >= 15) return Colors.green;
    return Colors.blue;
  }

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = dt.hour;
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  // ─── Current Weather Card ──────────────────────────────────────────────
  Widget _buildCurrentWeather() {
    final temp = (_current!['main']['temp'] as num).toDouble();
    final feelsLike = (_current!['main']['feels_like'] as num).toDouble();
    final humidity = _current!['main']['humidity'];
    final windSpeed = (_current!['wind']['speed'] as num).toDouble();
    final description = _current!['weather'][0]['description'] ?? '';
    final mainWeather = _current!['weather'][0]['main'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _tempColor(temp).withValues(alpha: 0.8),
            _tempColor(temp).withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            _weatherEmoji(mainWeather),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 8),
          Text(
            '${temp.round()}°C',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            description.toString().toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoChip('🌡️ Feels', '${feelsLike.round()}°C'),
              _infoChip('💧 Humidity', '$humidity%'),
              _infoChip('💨 Wind', '${windSpeed.round()} m/s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  // ─── Farming Tip Card ──────────────────────────────────────────────────
  Widget _buildFarmingTip() {
    final temp = (_current!['main']['temp'] as num).toDouble();
    final humidity = _current!['main']['humidity'] as int;
    final mainWeather = _current!['weather'][0]['main'] ?? '';

    String tip;
    IconData icon;
    Color color;

    if (mainWeather == 'Rain' || mainWeather == 'Thunderstorm') {
      tip =
          '🌧️ Rain expected — do NOT harvest today. '
          'Wet crops spoil faster and fetch lower prices.';
      icon = Icons.warning_amber_rounded;
      color = Colors.red;
    } else if (temp > 40) {
      tip =
          '🔥 Extreme heat — harvest early morning before 8 AM. '
          'Crops spoil 2x faster above 40°C. Use wet jute bags.';
      icon = Icons.warning_amber_rounded;
      color = Colors.red;
    } else if (temp > 35) {
      tip =
          '☀️ Hot day — sell quickly or store in shade with '
          'wet covering. Avoid transporting during 12-3 PM.';
      icon = Icons.info_outline;
      color = Colors.orange;
    } else if (humidity > 80) {
      tip =
          '💧 High humidity — risk of fungal damage. '
          'Keep crops dry and well-ventilated.';
      icon = Icons.info_outline;
      color = Colors.orange;
    } else {
      tip =
          '✅ Good weather for harvesting and transport. '
          'Conditions are favorable today.';
      icon = Icons.check_circle_outline;
      color = Colors.green;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farming Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tip, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 24h Forecast ──────────────────────────────────────────────────────
  Widget _buildForecast() {
    if (_forecast == null || _forecast!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Next 24 Hours',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _forecast!.length,
            itemBuilder: (context, index) {
              final item = _forecast![index];
              final temp = (item['main']['temp'] as num).toDouble();
              final main = item['weather'][0]['main'] ?? '';
              final dt = item['dt'] as int;

              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _formatTime(dt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _weatherEmoji(main),
                      style: const TextStyle(fontSize: 28),
                    ),
                    Text(
                      '${temp.round()}°C',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _tempColor(temp),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌦️ Weather — Nagpur'),
        backgroundColor: Colors.white,
        foregroundColor: AgriChainTheme.darkText,
        elevation: 1,
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AgriChainTheme.primaryGreen),
                  SizedBox(height: 16),
                  Text(
                    'Loading weather data... 🌤️',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchWeather,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AgriChainTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchWeather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentWeather(),
                    const SizedBox(height: 16),
                    _buildFarmingTip(),
                    const SizedBox(height: 8),
                    _buildForecast(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
