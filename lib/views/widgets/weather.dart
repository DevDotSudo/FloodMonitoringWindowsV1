import 'dart:async';
import 'package:flood_monitoring/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final WeatherApiService _weatherService = WeatherApiService();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _currentTime = DateTime.now();
  Timer? _timer; 

  @override
  void initState() {
    super.initState();
    _fetchWeather();

    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await _weatherService.fetchWeatherData(
        latitude: 11.000592,
        longitude: 122.8155554,
      );
      if (!mounted) return;
      setState(() => _weatherData = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to load weather');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildCardContainer(
      child: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildWeatherContent(),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: _errorMessage != null
              ? Colors.red.shade400
              : const Color.fromARGB(255, 209, 209, 209),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: child,
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWeatherContent() {
    final weather = _weatherData!;
    final isDay = weather.dateTime.hour >= 6 && weather.dateTime.hour < 18;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderSection(weather, isDay),
        _buildTemperatureSection(weather),
        _buildWeatherDetailsSection(weather),
        _buildForecastSection(weather),
      ],
    );
  }

  Widget _buildHeaderSection(WeatherData weather, bool isDay) {
    return Row(
      children: [
        Icon(
          getWeatherIconFromCode(weather.weatherConditionCode, isDay),
          color: Colors.amber.shade700,
          size: 42.0,
        ),
        const SizedBox(width: 15.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather.cityName,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              DateFormat('MMM dd, hh:mm a').format(_currentTime),
              style: TextStyle(fontSize: 15.0, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTemperatureSection(WeatherData weather) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '${weather.temperatureCelsius.round()}°C',
        style: const TextStyle(
          fontSize: 60.0,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsSection(WeatherData weather) {
    return Column(
      children: [
        _buildWeatherDetailRow(
          'Chance of Rain',
          '${weather.chanceOfRain.round()}%',
        ),
        _buildDivider(),
        _buildWeatherDetailRow('Wind', '${weather.windSpeedKmh.round()} km/h'),
        _buildDivider(),
        _buildWeatherDetailRow(
          'Heat Index',
          'Feels Like ${weather.feelsLikeCelsius.round()}°C',
        ),
        _buildDivider(),
        _buildWeatherDetailRow(
          'Humidity',
          '${weather.humidityPercent}%',
          isBoldValue: true,
        ),
      ],
    );
  }

  Widget _buildForecastSection(WeatherData weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weather.forecast
          .map(
            (item) => _buildForecastItem(
              item.timeOrTemp,
              item.icon,
              item.detail,
              Colors.blueGrey.shade600,
            ),
          )
          .toList(),
    );
  }

  Widget _buildWeatherDetailRow(
    String label,
    String value, {
    bool isBoldValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 17.0, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade300, height: 1.0, thickness: 1.0);
  }

  Widget _buildForecastItem(
    String timeOrTemp,
    IconData icon,
    String detail,
    Color iconColor,
  ) {
    return Column(
      children: [
        Text(
          timeOrTemp,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8.0),
        Icon(icon, color: iconColor, size: 32.0),
        const SizedBox(height: 8.0),
        Text(
          detail,
          style: TextStyle(fontSize: 15.0, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
