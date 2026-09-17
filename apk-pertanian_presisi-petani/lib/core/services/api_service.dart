import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/forum_model.dart';
import '../../models/standar_komoditas_model.dart';
import '../../models/wilayah_model.dart';
import '../constants/sumenep_master_data.dart';

class ApiService {
  // Configurable base URL with live and fallback alternatives
  static String baseUrl = 'https://demo.codingsolver.my.id';

  /// Safe JSON decoding that strictly validates HTTP status and content-type
  /// Prevents crashes from Cloudflare HTML (e.g. error 1033) or invalid responses
  static dynamic _safeJsonDecode(http.Response response) {
    try {
      final contentType = response.headers['content-type'] ?? '';
      final body = response.body.trim();

      // If content-type is HTML or body starts with HTML tag, fail gracefully
      if (contentType.contains('text/html') || body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
        debugPrint('[ApiService] Server returned HTML page instead of JSON. Status: ${response.statusCode}');
        return null;
      }

      if (body.isEmpty) return null;
      return json.decode(body);
    } catch (e) {
      debugPrint('[ApiService] JSON decode error: $e');
      return null;
    }
  }

  // Auth: Login
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final emailParam = identifier.contains('@')
          ? identifier.trim()
          : '${identifier.replaceAll(RegExp(r'[^0-9]'), '')}@pertanian.sumenep.go.id';

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailParam,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 8));

      final data = _safeJsonDecode(response);
      if (response.statusCode == 200 && data != null && data['status'] == true) {
        return {'success': true, 'data': data['data'], 'message': data['message'] ?? 'Login berhasil'};
      } else {
        return {'success': false, 'message': data?['message'] ?? 'Login gagal. Periksa nomor telepon/email dan password.'};
      }
    } catch (e) {
      debugPrint('[ApiService] Login network error: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server ($e)'};
    }
  }

  // Auth: Register
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String phone,
    required String password,
    required String role,
    required int desaId,
    String? nik,
    String? email,
  }) async {
    try {
      final emailParam = (email != null && email.isNotEmpty)
          ? email.trim()
          : (phone.contains('@') ? phone : '${phone.replaceAll(RegExp(r'[^0-9]'), '')}@pertanian.sumenep.go.id');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama': nama,
          'email': emailParam,
          'no_hp': phone,
          'password': password,
          'role': role,
          'desa_id': desaId,
          if (nik != null) 'nik': nik,
        }),
      ).timeout(const Duration(seconds: 8));

      final data = _safeJsonDecode(response);
      if ((response.statusCode == 200 || response.statusCode == 201) && data != null && data['status'] == true) {
        return {'success': true, 'data': data['data'], 'message': data['message'] ?? 'Registrasi berhasil'};
      } else {
        return {'success': false, 'message': data?['message'] ?? 'Registrasi gagal'};
      }
    } catch (e) {
      debugPrint('[ApiService] Register network error: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server ($e)'};
    }
  }

  // 1. Fetch Sumenep Wilayah with Instant Offline Fallback
  static Future<List<DesaModel>> getSumenepWilayah({String? kecamatan, String? query}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/wilayah/sumenep').replace(
        queryParameters: {
          if (kecamatan != null && kecamatan.isNotEmpty) 'kecamatan': kecamatan,
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response);
        if (data != null && data['data'] is List) {
          final list = (data['data'] as List)
              .map((item) => DesaModel.fromJson(item as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] Wilayah API offline/failed ($e), using embedded Sumenep master dataset.');
    }

    // Offline Fallback from 27 Kecamatan Dataset
    var offlineList = SumenepMasterData.offlineDesaList;
    if (kecamatan != null && kecamatan.isNotEmpty) {
      offlineList = offlineList.where((d) => d.kecamatan.toLowerCase() == kecamatan.toLowerCase()).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      if (q != 'sumenep' && q != 'kabupaten sumenep') {
        offlineList = offlineList.where((d) {
          return d.desa.toLowerCase().contains(q) || d.kecamatan.toLowerCase().contains(q);
        }).toList();
      }
    }
    return offlineList;
  }

  // 2. Fetch Paired Penyuluh for a Desa
  static Future<PairedPenyuluhModel?> getPairedPenyuluh(int desaId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/auth/me/$desaId'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response);
        if (data != null && data['data']?['paired_penyuluh'] != null) {
          return PairedPenyuluhModel.fromJson(
            data['data']['paired_penyuluh'] as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching paired penyuluh: $e');
    }
    return null;
  }

  // 3. Submit Custom Crop Standard (Farmer)
  static Future<Map<String, dynamic>> submitStandarPetani({
    required int petaniId,
    required int desaId,
    required String komoditas,
    required String varietas,
    required double minPh,
    required double maxPh,
    required double minMoisture,
    required double maxMoisture,
    required int minN,
    required int maxN,
    required int minP,
    required int maxP,
    required int minK,
    required int maxK,
    required double minTemp,
    required double maxTemp,
    required int minEc,
    required int maxEc,
    required int minFertility,
    required int maxFertility,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/petani/standar/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'petani_id': petaniId,
          'desa_id': desaId,
          'komoditas': komoditas,
          'varietas': varietas,
          'min_ph': minPh,
          'max_ph': maxPh,
          'min_moisture': minMoisture,
          'max_moisture': maxMoisture,
          'min_n': minN,
          'max_n': maxN,
          'min_p': minP,
          'max_p': maxP,
          'min_k': minK,
          'max_k': maxK,
          'min_temp': minTemp,
          'max_temp': maxTemp,
          'min_ec': minEc,
          'max_ec': maxEc,
          'min_fertility': minFertility,
          'max_fertility': maxFertility,
        }),
      ).timeout(const Duration(seconds: 8));

      final data = _safeJsonDecode(response);
      if (data != null && (response.statusCode == 200 || response.statusCode == 201)) {
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil mengajukan standar komoditas',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data?['message'] ?? 'Server offline atau mengembalikan status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi ke server gagal: $e',
      };
    }
  }

  // 4. Fetch Submitted Standards for Farmer
  static Future<List<StandarKomoditasModel>> getMyStandards(int petaniId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/petani/standar/my-standards?petani_id=$petaniId'))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response);
        if (data != null && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => StandarKomoditasModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching farmer standards: $e');
    }
    return [];
  }

  // 5. Fetch Community Forum Posts
  static Future<List<ForumPostModel>> getForumPosts({int limit = 50, int offset = 0}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/forum/posts?limit=$limit&offset=$offset'))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response);
        if (data != null && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => ForumPostModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching forum posts: $e');
    }
    return [];
  }

  // 6. Create Forum Post
  static Future<Map<String, dynamic>> createForumPost({
    required int userId,
    int? standarId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/forum/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'standar_id': standarId,
          'title': title,
          'body': body,
        }),
      ).timeout(const Duration(seconds: 8));

      final data = _safeJsonDecode(response);
      if (data != null && (response.statusCode == 200 || response.statusCode == 201)) {
        return {
          'success': true,
          'message': data['message'] ?? 'Postingan berhasil dibuat',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data?['message'] ?? 'Gagal membuat postingan (Kode: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membuat postingan: $e',
      };
    }
  }

  // 7. Add Comment to Forum Post
  static Future<Map<String, dynamic>> addForumComment({
    required int postId,
    required int userId,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/forum/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'post_id': postId,
          'user_id': userId,
          'comment': comment,
        }),
      ).timeout(const Duration(seconds: 8));

      final data = _safeJsonDecode(response);
      if (data != null && (response.statusCode == 200 || response.statusCode == 201)) {
        return {
          'success': true,
          'message': data['message'] ?? 'Komentar berhasil ditambahkan',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data?['message'] ?? 'Gagal mengirim komentar (Kode: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menambahkan komentar: $e',
      };
    }
  }

  // 8. Get Post Details with Comments
  static Future<ForumPostModel?> getForumPostDetail(int postId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/forum/posts/$postId'))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response);
        if (data != null && data['data'] != null) {
          return ForumPostModel.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Error fetching forum post detail: $e');
    }
    return null;
  }
}
