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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onSendAlertPressed() async {
    final String message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message cannot be empty')));
      return;
    }

    if (!_notifyOnApp && !_sendSms && !_gsmModule) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one delivery method (App or SMS).'),
        ),
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
        // String recipients = await _subscriberController.phoneNumbers();
        if (_gsmModuleService.connect("COM4")) {
          await _gsmModuleService.sendMessage("+639944934153", message);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warning alert sent successfully!')),
      );

      _messageController.clear();
      setState(() {
        _notifyOnApp = false;
        _sendSms = false;
        _gsmModule = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending alert: $e')));
      print('Error: " $e');
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
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Character count: ${_messageController.text.length}/160 (SMS limit guidance)',
                      style: TextStyle(
                        fontSize: 12,
                        color: _messageController.text.length > 160
                            ? AppColors.errorRed
                            : AppColors.textGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Send To',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: 'app-subscribers',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.lightGreyBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
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
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'app-subscribers',
                        child: Text(
                          'All App Subscribers',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'sms-only',
                        child: Text(
                          'All SMS Subscribers (via registered numbers)',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      print('Selected: $value');
                    },
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                    iconEnabledColor: AppColors.textGrey,
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCheckboxTile(
                          title: 'Notify on App',
                          value: _notifyOnApp,
                          onChanged: (bool? value) {
                            setState(() {
                              _notifyOnApp = value ?? false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildCheckboxTile(
                          title: 'Send SMS',
                          value: _sendSms,
                          onChanged: (bool? value) {
                            setState(() {
                              _sendSms = value ?? false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildCheckboxTile(
                          title: 'GSM Module',
                          value: _gsmModule,
                          onChanged: (bool? value) {
                            setState(() {
                              _gsmModule = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
                  if (_sendWarningController.alertStatusMessage.isNotEmpty &&
                      !_sendWarningController.isLoading) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _sendWarningController.alertStatusMessage
                                .toLowerCase()
                                .contains('success')
                            ? AppColors.statusNormalBg.withOpacity(0.2)
                            : _sendWarningController.alertStatusMessage
                                  .toLowerCase()
                                  .contains('fail')
                            ? AppColors.statusAlertBg.withOpacity(0.2)
                            : AppColors.statusInfoBg.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _sendWarningController.alertStatusMessage
                                  .toLowerCase()
                                  .contains('success')
                              ? AppColors.statusNormalText.withOpacity(0.4)
                              : _sendWarningController.alertStatusMessage
                                    .toLowerCase()
                                    .contains('fail')
                              ? AppColors.statusAlertText.withOpacity(0.4)
                              : AppColors.statusInfoText.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        _sendWarningController.alertStatusMessage,
                        style: TextStyle(
                          color:
                              _sendWarningController.alertStatusMessage
                                  .toLowerCase()
                                  .contains('success')
                              ? AppColors.statusNormalText
                              : _sendWarningController.alertStatusMessage
                                    .toLowerCase()
                                    .contains('fail')
                              ? AppColors.statusAlertText
                              : AppColors.statusInfoText,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
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
