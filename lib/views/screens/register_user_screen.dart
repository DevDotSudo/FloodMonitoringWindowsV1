import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/subscriber_controller.dart';
import 'package:flood_monitoring/models/subscriber.dart';
import 'package:flood_monitoring/views/widgets/button.dart';
import 'package:flood_monitoring/views/widgets/card.dart';
import 'package:flood_monitoring/views/widgets/confirmation_dialog.dart';
import 'package:flood_monitoring/views/widgets/message_dialog.dart';
import 'package:flood_monitoring/views/widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _subscriberController = SubscriberController();
  final _uuid = Uuid();
  bool _isLoading = false;
  String? selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final currentContext = context;
    setState(() => _isLoading = true);
    try {
      final result = await CustomConfirmationDialog.show(
        context: currentContext,
        title: 'Add User',
        message: 'Do you want to add this user?',
        confirmText: 'Add',
        cancelText: 'Cancel',
        confirmColor: AppColors.accentBlue,
        cancelColor: Colors.red.shade300,
      );

      if (!mounted) return;

      if (result == true) {
        _subscriberController.addSubscriber(
          Subscriber(
            id: _uuid.v4(),
            name: _fullNameController.text.trim(),
            age: _ageController.text.trim(),
            gender: selectedGender ?? 'Other',
            address: _addressController.text.trim(),
            phone: _phoneNumberController.text.trim(),
            registeredDate: DateFormat(
              'MMMM d, yyyy - h:mm a',
            ).format(DateTime.now()),
            viaSMS: 'Yes',
            viaApp: 'No',
          ),
        );

        await MessageDialog.show(
          context: currentContext,
          title: "Registration Successful",
          message: 'Subscriber added successfully.',
        );
        clearForm();
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
      clearForm();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void clearForm() {
    setState(() {
      _fullNameController.clear();
      _ageController.clear();
      _phoneNumberController.clear();
      _addressController.clear();
      selectedGender = null;
    });
  }

  void _showErrorDialog(String message) {
    MessageDialog.show(context: context, title: 'Error', message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: CustomCard(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Register New User',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
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
                        const SizedBox(height: 28),
                        _buildFormField(
                          label: 'Full Name',
                          controller: _fullNameController,
                          hintText: 'e.g., John Doe',
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Full Name is required' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildFormField(
                          label: 'Age',
                          controller: _ageController,
                          hintText: 'e.g., 30',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Age is required';
                            final age = int.tryParse(value!);
                            if (age == null || age <= 0 || age > 120) {
                              return 'Enter a valid age (1-120)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildGenderDropdown(),
                        const SizedBox(height: 20),
                        _buildFormField(
                          label: 'Phone Number',
                          controller: _phoneNumberController,
                          hintText: 'e.g., +63 912 345 6789',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Phone number is required';
                            }
                            final phoneRegex = RegExp(r'^(?:\+63|0)\d{10,12}$');
                            if (!phoneRegex.hasMatch(value!)) {
                              return 'Enter a valid Philippine phone number (e.g., +63912..., 0912...)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildFormField(
                          label: 'Address',
                          controller: _addressController,
                          hintText: 'e.g., Brgy. Libertad, Banate, Iloilo City',
                          maxLines: 3,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Address is required' : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Register User',
                            onPressed: _isLoading ? null : _submitForm,
                            color: AppColors.primary,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentBlue,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType,
          fillColor: AppColors.lightGreyBackground,
          borderRadius: 12,
          validator: validator,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(selectedGender),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightGreyBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintText: 'Select Gender',
            hintStyle: const TextStyle(
              color: AppColors.textGrey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.lightBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.lightBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accentBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
          ),
          value: selectedGender,
          items: _genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(
                gender,
                style: const TextStyle(
                  color: AppColors.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() => selectedGender = newValue);
          },
          validator: (value) => value == null ? 'Please select a gender' : null,
          dropdownColor: AppColors.cardBackground,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
          ),
          iconEnabledColor: AppColors.textGrey,
        ),
      ],
    );
  }
}
