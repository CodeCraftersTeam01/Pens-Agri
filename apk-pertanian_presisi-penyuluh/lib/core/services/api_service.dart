import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/soil_sample_model.dart';

class ApiResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const ApiResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });
}

class ApiService {
  static const String baseUrl = 'https://demo.codingsolver.my.id/api';
  static const String saveSoilEndpoint = '$baseUrl/soil/penyuluh/save';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Synchronizes the complete soil sample record (metadata + 3 binary photos) to the backend.
  Future<ApiResponse> saveSoilSample(SoilSampleModel sample) async {
    try {
      final Uri uri = Uri.parse(saveSoilEndpoint);
      final http.MultipartRequest request = http.MultipartRequest('POST', uri);

      // 1. Add all textual & numerical telemetry fields
      request.fields.addAll(sample.toFormFieldMap());

      // 2. Attach the 3 mandatory binary image files if available
      if (sample.fotoDaunPath != null && sample.fotoDaunPath!.isNotEmpty) {
        final File file = File(sample.fotoDaunPath!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('foto_daun', sample.fotoDaunPath!),
          );
        }
      }

      if (sample.fotoPohonPath != null && sample.fotoPohonPath!.isNotEmpty) {
        final File file = File(sample.fotoPohonPath!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('foto_pohon', sample.fotoPohonPath!),
          );
        }
      }

      if (sample.fotoTanahPath != null && sample.fotoTanahPath!.isNotEmpty) {
        final File file = File(sample.fotoTanahPath!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('foto_tanah', sample.fotoTanahPath!),
          );
        }
      }

      // 3. Send the Multipart Request
      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final dynamic json = jsonDecode(response.body);
          final bool status = json is Map && json['status'] == true;
          final String msg = (json is Map && json['message'] != null)
              ? json['message'].toString()
              : 'Data berhasil disimpan ke cloud!';
          return ApiResponse(
            isSuccess: status || response.statusCode == 200,
            message: msg,
            data: json,
          );
        } catch (_) {
          return ApiResponse(
            isSuccess: true,
            message: 'Data berhasil diterima oleh server (200 OK).',
          );
        }
      } else {
        return ApiResponse(
          isSuccess: false,
          message: 'Server menolak data (Kode: ${response.statusCode}).',
        );
      }
    } on SocketException {
      return const ApiResponse(
        isSuccess: false,
        message: 'Koneksi internet bermasalah. Pastikan perangkat online.',
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'Gagal sinkronisasi data ke cloud: $e',
      );
    }
  }
}
