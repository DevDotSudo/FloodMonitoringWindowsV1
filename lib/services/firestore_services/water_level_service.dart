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
        .asyncMap((snapshot) async {
          return snapshot.docs.map((doc) {
            return WaterLevelDataPoint(
              time: doc['hour'],
              level: doc['level'],
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
