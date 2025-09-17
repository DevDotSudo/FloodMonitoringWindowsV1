import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class GsmSender {
  late SerialPort _port;
  late SerialPortReader _reader;
  late StreamSubscription<Uint8List> _subscription;
  final StringBuffer _buffer = StringBuffer();

  bool connect(String portName) {
    try {
      _port = SerialPort(portName);

      if (!_port.openReadWrite()) {
        print("❌ Failed to open $portName");
        return false;
      }

      _port.config = SerialPortConfig()
        ..baudRate = 9600
        ..bits = 8
        ..stopBits = 1
        ..parity = 0;

      _reader = SerialPortReader(_port);
      _subscription = _reader.stream.listen((data) {
        final text = utf8.decode(data, allowMalformed: true);
        _buffer.write(text);
        print("📥 $text");
      });

      // Initialize modem
      sendAT("AT+CMGF=1", 500);   // SMS text mode
      sendAT("AT+CNMI=2,2,0,0,0", 500); // New message indication
      print("✅ Connected to $portName");
      return true;
    } catch (e) {
      print("❌ Error connecting: $e");
      return false;
    }
  }

  Future<String> sendAT(String command, int waitMs) async {
    _buffer.clear();
    _port.write(Uint8List.fromList(utf8.encode("$command\r")));
    await Future.delayed(Duration(milliseconds: waitMs));
    return _buffer.toString();
  }

  Future<bool> sendMessage(String phoneNumber, String message) async {
    try {
      String res = await sendAT("AT", 500);
      if (!res.contains("OK")) {
        print("❌ Modem not responding: $res");
        return false;
      }

      await sendAT("AT+CMGF=1", 500); // text mode

      String resp = await sendAT('AT+CMGS="$phoneNumber"', 1000);
      if (!resp.contains(">")) {
        print("❌ No '>' prompt: $resp");
        return false;
      }

      // Write message + CTRL+Z
      _port.write(Uint8List.fromList(utf8.encode(message + String.fromCharCode(26))));

      await Future.delayed(Duration(seconds: 5));
      String out = _buffer.toString();

      if (out.contains("OK")) {
        print("✅ Sent to $phoneNumber");
        return true;
      } else {
        print("❌ Failed: $out");
        return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      return false;
    }
  }

  void dispose() {
    _subscription.cancel();
    _port.close();
  }
}
