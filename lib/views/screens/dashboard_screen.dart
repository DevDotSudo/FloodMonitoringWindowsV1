import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/subscriber_controller.dart';
import 'package:flood_monitoring/controllers/water_level_data_controller.dart';
import 'package:flood_monitoring/models/water_level_data.dart';
import 'package:flood_monitoring/shared_pref.dart';
import 'package:flood_monitoring/views/widgets/card.dart';
import 'package:flood_monitoring/views/widgets/water_level_graph.dart';
import 'package:flood_monitoring/views/widgets/weather.dart';
import 'package:flutter/material.dart';
import 'package:flood_monitoring/services/alert_service/audio_alert_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final audioService = AudioPlayerService();
  final SubscriberController _subscriberController = SubscriberController();
  final WaterLevelDataController _waterLevelController =
      WaterLevelDataController();

  int? totalSubscribers;
  String? _adminName;
  bool _loadingName = true;

  @override
  void initState() {
    super.initState();
    _loadSubscribersCount();
    _loadAdminName();
  }

  Future<void> _loadSubscribersCount() async {
    int? total = await _subscriberController.countTotalSubscribers;
    setState(() {
      totalSubscribers = total;
    });
  }

  Future<void> _loadAdminName() async {
    final adminName = await SharedPref.getString('admin_name');
    if (mounted) {
      setState(() {
        _adminName = adminName;
        _loadingName = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<WaterLevelDataPoint>>(
        stream: _waterLevelController.watchWaterLevels(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? [];
          _waterLevelController.liveWaterLevelData = data;
          final currentLevel = _waterLevelController.currentWaterLevel;
          final status = _waterLevelController.riverStatus;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_loadingName)
                        const SizedBox(height: 40)
                      else
                        Text(
                          _adminName == null || _adminName!.isEmpty
                              ? 'Welcome Admin'
                              : 'Welcome, $_adminName',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      const SizedBox(height: 8),
                      const Text(
                        'Dashboard Overview',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = 3;
                          return GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 45,
                            childAspectRatio: 3,
                            children: [
                              _buildSubscribersCard(totalSubscribers ?? 0),
                              _buildWaterLevelCard(currentLevel.toStringAsFixed(2)),
                              _buildRiverStatusCard(status),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Water Level Monitoring',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Today's Weather",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ), 
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, 
                        children: [
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 600, 
                              child:
                                  snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : data.isNotEmpty
                                  ? WaterLevelGraph(dataPoints: data)
                                  : const Center(
                                      child: Text('No data available'),
                                    ),
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                          ), 
                          Expanded(
                            child: SizedBox(
                              height: 550,
                              width: double.infinity,
                              child: WeatherCard(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: iconColor, width: 6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 38),
          ),
          const SizedBox(width: 34),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.isEmpty || status.contains('No readings.')) {
      return const Color(0xFF3B82F6);
    }
    return status == "Normal"
        ? const Color(0xFF059669)
        : status == "Warning"
        ? const Color(0xFFF59E0B)
        : const Color(0xFFDC2626);
  }

  Widget _buildSubscribersCard(int subscriberCount) {
    return _buildMetricCard(
      icon: Icons.people,
      iconColor: const Color(0xFF3B82F6),
      label: 'Total Subscribers',
      value: subscriberCount.toString(),
    );
  }

  Widget _buildWaterLevelCard(String waterLevel) {
    return _buildMetricCard(
      icon: Icons.water_drop,
      iconColor: const Color(0xFF3B82F6),
      label: 'Current Water Level',
      value: waterLevel,
    );
  }

  Widget _buildRiverStatusCard(String status) {
    return _buildMetricCard(
      icon: Icons.warning,
      iconColor: _getStatusColor(status),
      label: 'River Status',
      value: status,
    );
  }
}
