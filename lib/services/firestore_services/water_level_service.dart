import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_monitoring/models/water_level_data.dart';
import 'package:flood_monitoring/services/alert_service/audio_alert_service.dart';
import 'package:flood_monitoring/services/alert_service/notification_alert_service.dart';

class WaterLevelService {
  final _waterLevelsRef = FirebaseFirestore.instance.collection('WATER_LEVEL');
  final _audioService = AudioPlayerService();
  final _notificationService = NotificationAlertService();
  String? _lastStatus;

  Stream<List<WaterLevelDataPoint>> watchWaterLevels() {
    return _waterLevelsRef
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;

          final latestDocs = docs.length > 7
              ? docs.sublist(docs.length - 7)
              : docs;

          return latestDocs.map((doc) {
            return WaterLevelDataPoint(
              time: doc['hour'],
              level: (doc['level'] ?? 0).toDouble(),
              status: doc['status'],
            );
          }).toList();
        });
  }

  Stream<List<WaterLevelDataPoint>> watchRecentReadings() {
    return _waterLevelsRef
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs;
      final recentDocs =
          docs.length > 7 ? docs.sublist(0, docs.length - 7) : [];

      return recentDocs.map((doc) {
        return WaterLevelDataPoint(
          time: doc['hour'],
          level: (doc['level'] ?? 0).toDouble(),
          status: doc['status'],
        );
      }).toList();
    });
  }

  void startListening() {
    watchWaterLevels().listen((data) {
      if (data.isEmpty) return;
      final status = data.last.status;

      if (status != _lastStatus) {
        _lastStatus = status;

        if (status == 'Warning') {
          _audioService.playWarningSound();
          _notificationService.showAlert(
            'Warning',
            'River is rising. Monitor closely.',
          );
        } else if (status == 'Critical') {
          _audioService.playCriticaltSound();
          _notificationService.showAlert(
            'Critical Alert',
            'River level is critical. Take action!',
          );
        } else {
          _audioService.stop();
        }
      }
    });
  }
}
