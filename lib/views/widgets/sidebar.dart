import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/navigation_controller.dart';
import 'package:flood_monitoring/shared_pref.dart';
import 'package:flood_monitoring/views/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Provider.of<NavigationController>(context);

    return Container(
      width: 300,
      color: AppColors.primaryBackground,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/images/app_icon_desktop.png'),
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 2),
          const SizedBox(height: 16),
          _buildNavLink(
            context,
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            screenType: ScreenType.dashboard,
            navigationController: navigationController,
          ),
          _buildNavLink(
            context,
            icon: Icons.people_outline,
            label: 'Subscribers',
            screenType: ScreenType.subscribers,
            navigationController: navigationController,
          ),
          _buildNavLink(
            context,
            icon: Icons.water_drop_outlined,
            label: 'Water Level',
            screenType: ScreenType.waterLevelData,
            navigationController: navigationController,
          ),
          _buildNavLink(
            context,
            icon: Icons.person_add_outlined,
            label: 'Register User',
            screenType: ScreenType.registerUser,
            navigationController: navigationController,
          ),
          _buildNavLink(
            context,
            icon: Icons.warning_amber_outlined,
            label: 'Send Alert',
            screenType: ScreenType.sendWarningAlert,
            navigationController: navigationController,
          ),
          _buildNavLink(
            context,
            icon: Icons.settings,
            label: 'Settings',
            screenType: ScreenType.settings,
            navigationController: navigationController,
          ),
          const Spacer(),
          _buildLogoutButton(
            onTap: () async {
              final result = await CustomConfirmationDialog.show(
                context: context,
                title: 'Confirm Logout',
                message: 'Are you sure you want to logout?',
                confirmText: 'Logout',
                cancelText: 'Cancel',
                confirmColor: Colors.red,
              );
              if (result == true) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
                await SharedPref.remove('admin_id');
              }
            },
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
        ],
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ScreenType screenType,
    required NavigationController navigationController,
  }) {
    final bool isSelected = navigationController.currentScreen == screenType;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => navigationController.navigateTo(screenType),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(
                    color: AppColors.accentBlue.withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.accentBlue : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.accentBlue : Colors.white70,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton({
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(
                    color: AppColors.accentBlue.withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: isSelected ? AppColors.accentBlue : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
