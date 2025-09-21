import 'package:flood_monitoring/constants/app_colors.dart';
import 'package:flood_monitoring/controllers/send_warning_controller.dart';
import 'package:flood_monitoring/controllers/subscriber_controller.dart';
import 'package:flood_monitoring/services/firestore_services/app_warning_message.dart';
import 'package:flood_monitoring/services/warning_service/gsm_module_service.dart';
import 'package:flood_monitoring/views/widgets/button.dart';
import 'package:flood_monitoring/views/widgets/card.dart';
import 'package:flood_monitoring/views/widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SendWarningAlertScreen extends StatefulWidget {
  const SendWarningAlertScreen({super.key});

  @override
  State<SendWarningAlertScreen> createState() => _SendWarningAlertScreenState();
}

class _SendWarningAlertScreenState extends State<SendWarningAlertScreen> {
  final _subscriberController = SubscriberController();
  final _sendWarningController = SendWarningController();
  final _gsmModuleService = GsmSender();
  final TextEditingController _messageController = TextEditingController();

  bool _notifyOnApp = false;
  bool _gsmModule = false;
  bool _sendSms = false;

  @override
  void initState() {
    super.initState();
    _sendWarningController.addListener(_updateUi);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _sendWarningController.removeListener(_updateUi);
    super.dispose();
  }

  void _updateUi() {
    if (mounted) setState(() {});
  }

  /// 🔹 Reusable dialog
  Future<void> _showDialog({
    required String title,
    required String message,
    Color titleColor = AppColors.textDark,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: TextStyle(color: titleColor)),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _onSendAlertPressed() async {
    final String message = _messageController.text.trim();

    if (message.isEmpty) {
      await _showDialog(
        title: "Validation Error",
        message: "Message cannot be empty.",
        titleColor: AppColors.errorRed,
      );
      return;
    }

    if (!_notifyOnApp && !_sendSms && !_gsmModule) {
      await _showDialog(
        title: "No Delivery Method",
        message: "Select at least one delivery method (App, SMS, or GSM).",
        titleColor: AppColors.errorRed,
      );
      return;
    }

    try {
      if (_notifyOnApp && _sendSms) {
        _sendWarningController.appNotification();
        String recipients = await _subscriberController.phoneNumbers();
        await _sendWarningController.sendWarningAlert(
          message:
              'Banate MDRRMO (${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now())}): $message',
          recipient: recipients,
        );
      } else if (_notifyOnApp) {
        _sendWarningController.appNotification();
        AppWarningMessage().storeWarningMessage(message);
      } else if (_sendSms) {
        String recipients = await _subscriberController.phoneNumbers();
        await _sendWarningController.sendWarningAlert(
          message:
              'Banate MDRRMO (${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now())}): $message',
          recipient: recipients,
        );
      } else if (_gsmModule) {
        if (_gsmModuleService.connect("COM4")) {
          await _gsmModuleService.sendMessage("+639944934153", message);
        }
      }

      await _showDialog(
        title: "Success",
        message: "Warning alert sent successfully!",
        titleColor: AppColors.statusNormalText,
      );

      _messageController.clear();
      setState(() {
        _notifyOnApp = false;
        _sendSms = false;
        _gsmModule = false;
      });
    } catch (e) {
      await _showDialog(
        title: "Error",
        message: "Failed to send warning alert.\n\n$e",
        titleColor: AppColors.errorRed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: CustomCard(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(16.0),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send Warning Alert',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: AppColors.errorRed,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Message Input
                  Text(
                    'Message Content',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  CustomTextFormField(
                    maxLines: 8,
                    controller: _messageController,
                    hintText: 'Compose your warning message here...',
                    fillColor: AppColors.lightGreyBackground,
                    borderRadius: 12.0,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Character count: ${_messageController.text.length}/160',
                      style: TextStyle(
                        fontSize: 12,
                        color: _messageController.text.length > 160
                            ? AppColors.errorRed
                            : AppColors.textGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Checkboxes
                  Row(
                    children: [
                      Expanded(
                        child: _buildCheckboxTile(
                          title: 'Notify on App',
                          value: _notifyOnApp,
                          onChanged: (v) => setState(() => _notifyOnApp = v!),
                        ),
                      ),
                      Expanded(
                        child: _buildCheckboxTile(
                          title: 'Send SMS',
                          value: _sendSms,
                          onChanged: (v) => setState(() => _sendSms = v!),
                        ),
                      ),
                      Expanded(
                        child: _buildCheckboxTile(
                          title: 'GSM Module',
                          value: _gsmModule,
                          onChanged: (v) => setState(() => _gsmModule = v!),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _sendWarningController.isLoading
                          ? 'Sending...'
                          : 'Send Warning Alert',
                      onPressed: _sendWarningController.isLoading
                          ? null
                          : _onSendAlertPressed,
                      color: AppColors.errorRed,
                      textColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  if (_sendWarningController.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.accentBlue,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
