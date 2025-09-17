import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';

class AppNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final String _fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/capstone-flood-monitoring/messages:send';
  static const String _serviceAccountPath = 'assets/serviceAccount.json';

  Future<AccessCredentials> _getAccessToken() async {
    final jsonKey =
        jsonDecode(await File(_serviceAccountPath).readAsString())
            as Map<String, dynamic>;

    final accountCredentials = ServiceAccountCredentials.fromJson(jsonKey);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    return await obtainAccessCredentialsViaServiceAccount(
      accountCredentials,
      scopes,
      http.Client(),
    );
  }

  Future<void> sendToAllUsers({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final tokens = await _getAllActiveTokens();
    if (tokens.isEmpty) {
      print('No active tokens found');
      return;
    }

    for (final token in tokens) {
      await _sendNotification(
        token: token,
        title: title,
        body: body,
        data: data,
      );
    }
  }

  Future<List<String>> _getAllActiveTokens() async {
    final snapshot = await _firestore
        .collection('SUBSCRIBERS')
        .where('fcmToken', isNotEqualTo: null)
        .get();

    final tokens = snapshot.docs
        .map((doc) => doc.data()['fcmToken'] as String?)
        .where((token) => token != null)
        .cast<String>()
        .toSet()
        .toList();

    return tokens;
  }

  Future<void> _sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final accessToken = (await _getAccessToken()).accessToken.data;

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': data ?? {},
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Sent: ${response.body}');
      } else {
        print('Failed to send to $token: ${response.body}');
      }
    } catch (e) {
      print('Error sending to $token: $e');
    }
  }
}
