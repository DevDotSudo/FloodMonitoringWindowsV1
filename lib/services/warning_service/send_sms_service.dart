import 'dart:convert';
import 'package:http/http.dart' as http;

class SendWarningSMS {
  final String _apiToken = "2246|Gs1xhKUx4eVFqQxv3vMrhF24XxBxE7a66eWPxUhy ";
  final String _senderName = "PhilSMS";

  Future<void> sendSms(String message, String recipient) async {
    final url = Uri.parse("https://app.philsms.com/api/v3/sms/send"); 
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $_apiToken",
    };
    final body = jsonEncode({
      "sender_id": _senderName,
      "recipient": recipient,
      "message": message,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("SMS sent successfully.");
      } else {
        print("Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class SendWarningSMS {
//   final String _apiToken = "ljNf8yQmUMb2uPB3zlwr98PHlYztMsAk3MlhwEF302d8zxJmYrfaoAfFEiVGrgM5";

//   Future<void> sendSms(String message, String recipient) async {
//     final url = Uri.parse("https://sms.skyio.site/api/sms/send");
//     final headers = {
//       "Content-Type": "application/json",
//       "Authorization": "Bearer $_apiToken",
//     };
//     final body = jsonEncode({
//       "to": recipient,
//       "message": message,
//     });

//     try {
//       final response = await http.post(url, headers: headers, body: body);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print("Response: $data");

//         if (data['success'] == true) {
//           print("Message sent successfully!");
//         } else {
//           print("Error: ${data['message']}");
//         }
//       } else {
//         print("Failed: HTTP ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Request failed: $e");
//     }
//   }
// }
