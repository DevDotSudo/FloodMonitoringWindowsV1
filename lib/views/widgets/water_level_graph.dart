import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/constants/water_level_status.dart';
import 'package:flood_monitoring/controllers/water_level_data_controller.dart';
import 'package:flood_monitoring/models/water_level_data.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterLevelGraph extends StatelessWidget {
  final List<WaterLevelDataPoint> dataPoints;
  final WaterLevelDataController _waterLevelDataController =
      WaterLevelDataController();

  WaterLevelGraph({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.grey.shade50,
      ),
      child: LineChart(_buildChartData(dataPoints)),
    );
  }

  LineChartData _buildChartData(List<WaterLevelDataPoint> data) {
    if (data.isEmpty) {
      return LineChartData(
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [],
      );
    }

    _waterLevelDataController.liveWaterLevelData = dataPoints;
    final status = _waterLevelDataController.riverStatus;

    final lineColor = status == WaterLevelStatus.normal
        ? AppColors.normalStatus
        : status == WaterLevelStatus.warning
        ? AppColors.warningStatus
        : status == WaterLevelStatus.critical
        ? AppColors.criticalStatus
        : AppColors.info;

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((spot) {
            return LineTooltipItem(
              '${data[spot.x.toInt()].time}\n',
              const TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: '${spot.y.toStringAsFixed(1)}ft',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          }).toList(),
          getTooltipColor: (spot) => lineColor.withOpacity(0.8),
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipPadding: const EdgeInsets.all(8),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text(
            'Time (hour)',
            style: TextStyle(
              color: Color.fromARGB(255, 54, 66, 90),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          axisNameSize: 24,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _calculateBottomInterval(data.length),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= data.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  data[index].time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text(
            'Water Level (feet)',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          axisNameSize: 24,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value < 0) return const SizedBox.shrink();
              return Text(
                '${value.toInt()}ft',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade300),
      ),
      minX: 0,
      maxX: data.length.toDouble() - 1,
      minY: 0,
      maxY: 30,
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.level))
              .toList(),
          isCurved: true,
          color: lineColor,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  double _calculateBottomInterval(int dataLength) {
    if (dataLength <= 8) return 1;
    if (dataLength <= 12) return 2;
    if (dataLength <= 24) return 3;
    return (dataLength / 6).ceilToDouble();
  }
}
