import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/admin_controller.dart';
import 'package:flood_monitoring/services/mysql_services/admin_service.dart';
import 'package:flood_monitoring/views/main_layout.dart';
import 'package:flood_monitoring/views/screens/register_admin_screen.dart';
import 'package:flood_monitoring/views/widgets/button.dart';
import 'package:flood_monitoring/views/widgets/message_dialog.dart';
import 'package:flood_monitoring/views/widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flood_monitoring/shared_pref.dart';
import 'package:google_fonts/google_fonts.dart';

class DesktopLoginScreen extends StatefulWidget {
  const DesktopLoginScreen({super.key});

  @override
  State<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
}

class _DesktopLoginScreenState extends State<DesktopLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  final _adminController = AdminController(AdminService());

  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

  Future<void> _checkRememberMe() async {
    final remember = await SharedPref.getString('remember_me');
    final adminId = await SharedPref.getString('admin_id');
    if (remember == 'true' && adminId != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final isVerified = await _adminController.login(username, password);
      if (!mounted) return;

      if (!isVerified) {
        _showErrorDialog('Invalid username or password');
        return;
      }

      final adminName = await _adminController.getAdminNameByUsername(username);
      _showSuccessDialog('Welcome back, $adminName!', username);
      await _saveLoginData(username, adminName);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLoginData(String username, String? adminName) async {
    await SharedPref.setString('admin_name', adminName ?? 'Admin');
    if (_rememberMe) {
      final adminName = await _adminController.getAdminNameByUsername(username);
      await SharedPref.setString('username', username);
      await SharedPref.setString('admin_id', adminName ?? '');
      await SharedPref.setString('remember_me', 'true');
    }
  }

  void _navigateToMainLayout(String? adminName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  Future<void> _showSuccessDialog(String message, String username) async {
    final adminName = await _adminController.getAdminNameByUsername(username);
    MessageDialog.show(
      context: context,
      title: 'Login Successful',
      message: message,
      buttonText: 'OK',
      onPressed: () {
        _navigateToMainLayout(adminName);
      },
    );
  }

  void _showErrorDialog(String message) {
    MessageDialog.show(
      context: context,
      title: message.contains('Invalid') ? 'Login Failed' : 'Error',
      message: message,
      buttonText: 'OK',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.8,
            child: Image.asset(
              'assets/images/desktop_background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentBlue,
                  AppColors.accentBlue.withOpacity(0.5),
                ],
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 1000,
                  maxHeight: 600,
                ),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBackground,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(38),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(
                                  color: AppColors.accentBlue,
                                  width: 2,
                                ),
                              ),
                              child: const Image(
                                image: AssetImage(
                                  'assets/images/app_icon_desktop.png',
                                ),
                                width: 200,
                                height: 200,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Banate MDRRMO \nFlood Monitoring System',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ibmPlexSerif(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentBlue,
                                fontSize: 26,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right Side - Login Form
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 40,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(10),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back, Admin!',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Text(
                                'Please login your account.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 4,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildUsernameField(),
                              const SizedBox(height: 20),
                              _buildPasswordField(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false,
                                    ),
                                    activeColor: AppColors.accentBlue,
                                  ),
                                  const Text('Remember me'),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                text: 'LOGIN',
                                onPressed: _isLoading ? null : _login,
                                color: AppColors.accentBlue,
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterAdminScreen(),
                                    ),
                                  ),
                                  child: const Text.rich(
                                    TextSpan(
                                      text: "Create new admin account? ",
                                      children: [
                                        TextSpan(
                                          text: 'Register',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: _usernameController,
          hintText: 'Enter your username',
          keyboardType: TextInputType.text,
          fillColor: Colors.grey.shade50,
          borderRadius: 12,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter your username' : null,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: _passwordController,
          hintText: 'Enter your password',
          obscureText: !_passwordVisible,
          fillColor: Colors.grey.shade50,
          borderRadius: 12,
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey.shade500,
            ),
            onPressed: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter your password' : null,
        ),
      ],
    );
  }
}
