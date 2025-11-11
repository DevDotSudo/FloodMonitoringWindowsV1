import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/admin_controller.dart';
import 'package:flood_monitoring/services/mysql_services/admin_service.dart';
import 'package:flood_monitoring/shared_pref.dart';
import 'package:flood_monitoring/views/screens/desktop_login_screen.dart';
import 'package:flood_monitoring/views/widgets/change_password_dialog.dart';
import 'package:flood_monitoring/views/widgets/confirmation_dialog.dart';
import 'package:flood_monitoring/views/widgets/message_dialog.dart';
import 'package:flutter/material.dart';

class FloodMonitoringApp extends StatelessWidget {
  const FloodMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flood Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _adminData;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final adminService = AdminService();
    final adminController = AdminController(adminService);
    final username = await SharedPref.getString('username');
    if (username != null) {
      final admin = await adminController.getAdminByUsername(username);
      if (admin != null) {
        setState(() {
          _adminData = {
            'username': admin.username,
            'fullname': admin.fullName,
            'email': admin.email,
            'phoneNumber': admin.phoneNumber,
          };
        });
      }
    }
  }

  void deleteAdmin() async {
    final adminService = AdminService();
    final adminController = AdminController(adminService);
    final username = await SharedPref.getString('username');
    if (username != null) {
      final admin = await adminController.getAdminByUsername(username);
      if (admin != null) {
        final result = await CustomConfirmationDialog.show(
          context: context,
          title: 'Delete Account',
          message: 'Do you want to delete your account?',
          confirmText: 'Delete',
          cancelText: 'Cancel',
          confirmColor: AppColors.accentBlue,
          cancelColor: Colors.red.shade300,
        );

        if (result == true) {
          adminController.delete(admin.id!);
          SharedPref.remove('username');
          SharedPref.remove('remember_me');
          SharedPref.remove('admin_id');
          await MessageDialog.show(
            context: context,
            title: "Deleted Successfully",
            message: 'You will be directed to login screen.',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DesktopLoginScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              width: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSettingsSection(
                    title: 'Profile Information',
                    children: [
                      if (_adminData == null)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        _buildProfileRow('Username', _adminData!['username']),
                        _buildProfileRow('Full Name', _adminData!['fullname']),
                        _buildProfileRow('Email', _adminData!['email']),
                        _buildProfileRow(
                          'Phone Number',
                          _adminData!['phoneNumber'],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    title: 'Account Security',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final adminService = AdminService();
                                final username = await SharedPref.getString(
                                  'username',
                                );
                                final admin = await adminService
                                    .getAdminByUsername(username ?? '');
                                if (admin != null) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => ChangePasswordDialog(
                                      admin: admin,
                                      adminService: adminService,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Change Password',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: deleteAdmin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Delete Account',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF34495E),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
