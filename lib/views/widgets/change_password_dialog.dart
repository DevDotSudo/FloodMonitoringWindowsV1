import 'package:flutter/material.dart';
import 'package:flood_monitoring/views/widgets/button.dart';
import 'package:flood_monitoring/models/admin_registration.dart';
import 'package:flood_monitoring/services/mysql_services/admin_service.dart';
import 'package:flood_monitoring/utils/hash_util.dart';

class ChangePasswordDialog extends StatefulWidget {
  final AdminRegistration admin;
  final AdminService adminService;

  const ChangePasswordDialog({
    super.key,
    required this.admin,
    required this.adminService,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final hashUtil = HashPassword();

    final isValid = hashUtil.validPassword(
      _currentPasswordController.text.trim(),
      widget.admin.password,
    );
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current password is incorrect")),
      );
      setState(() => _isLoading = false);
      return;
    }

    final newHashedPassword = hashUtil.hashPassword(
      _newPasswordController.text.trim(),
    );

    try {
      final updatedAdmin = AdminRegistration(
        id: widget.admin.id,
        username: widget.admin.username,
        fullName: widget.admin.fullName,
        email: widget.admin.email,
        phoneNumber: widget.admin.phoneNumber,
        password: newHashedPassword,
      );

      await widget.adminService.updateAdmin(updatedAdmin);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating password: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                color: theme.primaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(Icons.lock, size: 48, color: theme.primaryColor),
                    const SizedBox(height: 16),
                    const Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Current Password",
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? "Enter your current password"
                          : null,
                    ),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                      ),
                      validator: (val) => val != null && val.length < 6
                          ? "Password must be at least 6 characters"
                          : null,
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirm New Password",
                      ),
                      validator: (val) =>
                          val != _newPasswordController.text.trim()
                          ? "Passwords do not match"
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Cancel",
                            onPressed: () => Navigator.pop(context),
                            isOutlined: true,
                            color: Colors.grey.shade700,
                            borderRadius: 8,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: _isLoading ? "Updating..." : "Update",
                            onPressed: _isLoading ? null : _changePassword,
                            color: theme.primaryColor,
                            borderRadius: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
