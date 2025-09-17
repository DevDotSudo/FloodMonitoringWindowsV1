import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/models/admin_registration.dart';
import 'package:flood_monitoring/services/mysql_services/admin_service.dart';
import 'package:flood_monitoring/views/widgets/button.dart';
import 'package:flood_monitoring/views/widgets/confirmation_dialog.dart';
import 'package:flood_monitoring/views/widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class RegisterAdminScreen extends StatefulWidget {
  const RegisterAdminScreen({super.key});

  @override
  State<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
}

class _RegisterAdminScreenState extends State<RegisterAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _uid = Uuid();
  bool _isLoading = false;
  late final AdminService _adminService;

  @override
  void initState() {
    super.initState();
    _adminService = AdminService();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final admin = AdminRegistration(
        id: _uid.v4(),
        username: _usernameController.text.trim(),
        fullName: _fullnameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      await _adminService.registerAdmin(admin);

      if (!mounted) return;
      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    final result = await CustomConfirmationDialog.show(
      context: context,
      title: 'Registration Successful',
      message: 'Admin account created successfully',
      confirmText: 'Go to Login',
      cancelText: 'Close',
      confirmColor: AppColors.accentBlue,
    );

    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await CustomConfirmationDialog.show(
      context: context,
      title: 'Registration Failed',
      message: message,
      confirmText: 'OK',
      confirmColor: Colors.red,
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
                  maxHeight: 700,
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
                        padding: const EdgeInsets.all(40),
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
                              padding: const EdgeInsets.all(45),
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
                            const SizedBox(height: 32),
                            Text(
                              'Admin Registration',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ibmPlexSerif(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentBlue,
                                fontSize: 32,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Create a new admin to manage the system.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ibmPlexSerif(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentBlue,
                                fontSize: 18,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right Side - Registration Form
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
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Create Admin Account',
                                  style: TextStyle(
                                    fontSize: 24,
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
                                const SizedBox(height: 32),
                                _buildFormField(
                                  label: 'Username',
                                  controller: _usernameController,
                                  hint: 'Enter username',
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Full Name',
                                  controller: _fullnameController,
                                  hint: 'Enter full name',
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Email',
                                  controller: _emailController,
                                  hint: 'Enter email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Required';
                                    }
                                    if (!value!.contains('@')) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Phone Number',
                                  controller: _phoneController,
                                  hint: 'Enter phone',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  hint: 'Enter password',
                                  obscureText: true,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Required';
                                    }
                                    if (value!.length < 6) {
                                      return 'Min 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildFormField(
                                  label: 'Confirm Password',
                                  controller: _confirmPasswordController,
                                  hint: 'Re-enter password',
                                  obscureText: true,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Required';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords don\'t match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                CustomButton(
                                  text: 'REGISTER',
                                  onPressed: _isLoading ? null : _submitForm,
                                  color: AppColors.accentBlue,
                                  isLoading: _isLoading,
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text.rich(
                                      TextSpan(
                                        text: 'Already have an account? ',
                                        children: [
                                          TextSpan(
                                            text: 'Login',
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: controller,
          hintText: hint,
          obscureText: obscureText,
          keyboardType: keyboardType,
          fillColor: Colors.grey.shade50,
          borderRadius: 12,
          validator: validator,
        ),
      ],
    );
  }
}
