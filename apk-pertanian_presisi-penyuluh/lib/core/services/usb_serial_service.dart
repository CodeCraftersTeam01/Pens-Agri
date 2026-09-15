import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../models/soil_sample_model.dart';

enum UsbStatus { disconnected, connecting, connected, error }

/// Singleton Hardware Service for CH340 / USB Serial Modbus RTU communication.
class UsbSerialService {
  static final UsbSerialService _instance = UsbSerialService._internal();
  factory UsbSerialService() => _instance;
  UsbSerialService._internal();

  static const MethodChannel _platform = MethodChannel('id.ac.pens/usb_serial');

  final ValueNotifier<UsbStatus> statusNotifier = ValueNotifier<UsbStatus>(UsbStatus.disconnected);
  final ValueNotifier<String> statusMessageNotifier = ValueNotifier<String>('Silakan Colok USB CH340 & Klik Konek');
  final ValueNotifier<SoilTelemetry> telemetryNotifier = ValueNotifier<SoilTelemetry>(SoilTelemetry.empty());
  final ValueNotifier<String> logsNotifier = ValueNotifier<String>('');

  bool get isConnected => statusNotifier.value == UsbStatus.connected;
  bool get hasReadSensor => telemetryNotifier.value.isValid;

  String _formatNow() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  void _appendLog(String text) {
    logsNotifier.value += "[${_formatNow()}] $text\n";
  }

  /// Connects to the attached USB Serial device
  Future<bool> connect() async {
    statusNotifier.value = UsbStatus.connecting;
    statusMessageNotifier.value = "Menghubungkan ke USB CH340...";
    try {
      final String result = await _platform.invokeMethod('connectCH340');
      statusNotifier.value = UsbStatus.connected;
      statusMessageNotifier.value = result;
      _appendLog(result);
      return true;
    } on PlatformException catch (e) {
      statusNotifier.value = UsbStatus.error;
      statusMessageNotifier.value = "${e.message}";
      _appendLog("Error Koneksi: ${e.message}");
      return false;
    } catch (e) {
      statusNotifier.value = UsbStatus.error;
      statusMessageNotifier.value = e.toString();
      _appendLog("Exception: $e");
      return false;
    }
  }

  /// Queries the 8-in-1 Modbus soil probe and parses the raw binary response.
  Future<SoilTelemetry?> readSensorData() async {
    if (!isConnected) {
      _appendLog("Gagal: Perangkat USB belum terhubung.");
      return null;
    }

    try {
      _appendLog("TX -> 01 03 00 00 00 08 44 0C");
      final List<dynamic> rawData = await _platform.invokeMethod('sendModbusQuery');
      final List<int> validFrame = rawData.cast<int>();

      final String hexString = validFrame
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(' ');
      _appendLog("RX <- $hexString");

      if (validFrame.length >= 21) {
        final int rawMoisture = (validFrame[3] << 8) | validFrame[4];
        final int rawTemp     = (validFrame[5] << 8) | validFrame[6];
        final int rawEC       = (validFrame[7] << 8) | validFrame[8];
        final int rawPH       = (validFrame[9] << 8) | validFrame[10];
        final int rawN        = (validFrame[11] << 8) | validFrame[12];
        final int rawP        = (validFrame[13] << 8) | validFrame[14];
        final int rawK        = (validFrame[15] << 8) | validFrame[16];
        final int rawFert     = (validFrame[17] << 8) | validFrame[18];

        final SoilTelemetry telemetry = SoilTelemetry(
          moisture: rawMoisture / 10.0,
          temp: rawTemp / 10.0,
          conductivity: rawEC,
          ph: rawPH / 10.0,
          nitrogen: rawN,
          phosphorus: rawP,
          potassium: rawK,
          fertility: rawFert,
          timestamp: DateTime.now(),
        );

        telemetryNotifier.value = telemetry;
        _appendLog("Parsed: Data 8 Parameter Sukses Diperbarui!");
        return telemetry;
      } else {
        _appendLog("Warning: Frame data tidak lengkap (< 21 bytes)");
        return null;
      }
    } on PlatformException catch (e) {
      _appendLog("Gagal Query: ${e.message}");
      return null;
    } catch (e) {
      _appendLog("Exception: $e");
      return null;
    }
  }

  /// Closes the USB serial connection
  Future<void> disconnect() async {
    try {
      final String result = await _platform.invokeMethod('disconnectCH340');
      statusNotifier.value = UsbStatus.disconnected;
      statusMessageNotifier.value = result;
      _appendLog(result);
      resetData();
    } catch (e) {
      statusNotifier.value = UsbStatus.disconnected;
      statusMessageNotifier.value = "Koneksi USB Terputus";
      _appendLog("Disconnect exception: $e");
    }
  }

  void resetData() {
    telemetryNotifier.value = SoilTelemetry.empty();
  }
}
