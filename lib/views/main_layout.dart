import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/navigation_controller.dart';
import 'package:flood_monitoring/views/screens/dashboard_screen.dart';
import 'package:flood_monitoring/views/screens/register_user_screen.dart';
import 'package:flood_monitoring/views/screens/send_warning_alert_screen.dart';
import 'package:flood_monitoring/views/screens/settings_screen.dart';
import 'package:flood_monitoring/views/screens/subscriber_screen.dart';
import 'package:flood_monitoring/views/screens/water_level_data_screen.dart';
import 'package:flood_monitoring/views/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navigationController, child) {
        return Scaffold(
          backgroundColor: AppColors.lightGreyBackground,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Sidebar(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildBody(navigationController.currentScreen),
                        ),
                      ),
                    ),
                    // Footer
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Developed by: Eric Dave Cala-or & Jefferson Arabit',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Version: 1.0.0',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ScreenType currentScreen) {
    switch (currentScreen) {
      case ScreenType.dashboard:
        return const DashboardScreen();
      case ScreenType.subscribers:
        return const SubscribersScreen();
      case ScreenType.waterLevelData:
        return WaterLevelDataScreen();
      case ScreenType.registerUser:
        return const RegisterUserScreen();
      case ScreenType.sendWarningAlert:
        return const SendWarningAlertScreen();
      case ScreenType.settings:
        return const SettingsScreen();
    }
  }
}
