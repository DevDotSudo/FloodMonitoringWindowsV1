import 'package:flood_monitoring/models/water_level_data.dart';
import 'package:flood_monitoring/services/firestore_services/water_level_service.dart';
import 'package:flutter/material.dart';

class WaterLevelDataController extends ChangeNotifier {
  final WaterLevelService _service = WaterLevelService();
  List<WaterLevelDataPoint> liveWaterLevelData = [];

  Stream<List<WaterLevelDataPoint>> watchWaterLevels() => 
    _service.watchWaterLevels() ;

  Stream<List<WaterLevelDataPoint>> watchRecentReadings() =>
    _service.watchRecentReadings();

  String get riverStatus {
    if (liveWaterLevelData.isEmpty) return 'No readings.';
    return liveWaterLevelData.last.status;
  }

  double get currentWaterLevel {
    if (liveWaterLevelData.isEmpty) return 0.0;
    return liveWaterLevelData.last.level;
  }

  void loadWaterLevels() {
    watchWaterLevels().listen((data) {
      liveWaterLevelData = data;
      notifyListeners();
    });
  }
}
