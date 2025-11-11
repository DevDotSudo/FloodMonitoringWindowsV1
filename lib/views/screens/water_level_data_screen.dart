import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/constants/water_level_status.dart';
import 'package:flood_monitoring/controllers/water_level_data_controller.dart';
import 'package:flood_monitoring/models/water_level_data.dart';
import 'package:flood_monitoring/views/widgets/card.dart';
import 'package:flood_monitoring/views/widgets/water_level_graph.dart';
import 'package:flutter/material.dart';

class WaterLevelDataScreen extends StatefulWidget {
  const WaterLevelDataScreen({super.key});

  @override
  State<WaterLevelDataScreen> createState() => _WaterLevelDataScreenState();
}

class _WaterLevelDataScreenState extends State<WaterLevelDataScreen> {
  final WaterLevelDataController _waterLevelController =
      WaterLevelDataController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WaterLevelDataPoint>>(
      stream: _waterLevelController.watchWaterLevels(),
      builder: (context, latestSnapshot) {
        final latest = latestSnapshot.data ?? [];

        return StreamBuilder<List<WaterLevelDataPoint>>(
          stream: _waterLevelController.watchRecentReadings(),
          builder: (context, recentSnapshot) {
            final recent = recentSnapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detailed Water Level Data',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 600,
                          child:
                              latestSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(child: CircularProgressIndicator())
                              : latest.isNotEmpty
                              ? WaterLevelGraph(dataPoints: latest)
                              : const Center(child: Text('No data available')),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Recent Readings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDataTable(recent),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
    Widget _buildDataTable(List<WaterLevelDataPoint> data) {
      final recent = data.take(1000).toList();
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DataTable(
            border: TableBorder.all(color: AppColors.textGrey),
            columnSpacing: 24,
            horizontalMargin: 16,
            dataRowMinHeight: 54,
            dataRowMaxHeight: 54,
            headingRowHeight: 54,
            headingRowColor: WidgetStateColor.resolveWith(
              (states) => Colors.grey.shade50,
            ),
            columns: const [
              DataColumn(
                label: Text(
                  'Time',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Level (f)',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
            rows: recent.map((point) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(point.time, style: const TextStyle(fontSize: 16)),
                  ),
                  DataCell(
                    Text(
                      point.level.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: point.status == WaterLevelStatus.warning
                            ? Colors.orange.shade100
                            : AppColors.statusNormalBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        point.status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: point.status == WaterLevelStatus.warning
                              ? Colors.orange
                              : point.status == WaterLevelStatus.critical
                              ? Colors.red
                              : AppColors.statusNormalText,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }
  }
