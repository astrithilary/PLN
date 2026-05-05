import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'auth_storage.dart';

class ApiService {
  static final Logger _logger = Logger();
  // Set via --dart-define=API_BASE_URL=http://IP_LAPTOP:8000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.18.46:8000/api',
  );

  // Endpoint disesuaikan dengan Route::post('/sync-pelanggan') di Laravel tadi
  static const String endpoint = '$baseUrl/sync-pelanggan';

  static Future<Map<String, String>> _jsonHeaders({
    bool authenticated = true,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Map<String, dynamic> _normalizePelangganData(
    Map<String, dynamic> data,
  ) {
    return {
      'nama': data['nama'],
      'alamat': data['alamat'],
      'no_meter': data['no_meter'] ?? data['id_pelanggan'] ?? '',
      'daya_listrik': data['daya_listrik'] ?? data['daya'],
      'no_hp': data['no_hp'],
      'foto_path': data['foto_path'],
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'waktu_kunjungan': data['waktu_kunjungan'],
    };
  }

  static Future<int?> savePelanggan(Map<String, dynamic> data) async {
    final payload = _normalizePelangganData(data);

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: await _jsonHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'] as int?;
      }

      _logger.w('Sync failed: ${response.statusCode} ${response.body}');
      return null;
    } on TimeoutException {
      _logger.e('Error API timeout ke $endpoint');
      return null;
    } catch (e) {
      _logger.e('Error API: $e');
      return null;
    }
  }

  // Kirim batch data pelanggan
  static Future<List<int>> saveBatchPelanggan(
    List<Map<String, dynamic>> dataList,
  ) async {
    List<int> successfulIds = [];

    for (var data in dataList) {
      try {
        final payload = _normalizePelangganData(data);
        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: await _jsonHeaders(),
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 201) {
          successfulIds.add(data['id'] as int);
        } else {
          _logger.w(
            'Batch sync failed: ${response.statusCode} ${response.body}',
          );
        }
      } catch (e) {
        _logger.e('Error saat send batch: $e');
      }
    }

    return successfulIds;
  }

  // Upload foto pelanggan (multipart)
  static Future<String?> uploadFoto(String filePath, int pelangganId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-foto/$pelangganId'),
      );

      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('foto', filePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['foto_path'];
      } else {
        _logger.w('Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error upload foto: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchTugas() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/tugas'),
            headers: await _jsonHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          // Asumsikan data adalah list of objects
          return List<Map<String, dynamic>>.from(data);
        } else if (data['data'] != null && data['data'] is List) {
          // Asumsikan data dibungkus di key 'data'
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        _logger.w('Fetch tugas failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error fetch tugas API: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: await _jsonHeaders(authenticated: false),
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      _logger.w('Login failed: ${response.statusCode} ${response.body}');
      return null;
    } on TimeoutException {
      _logger.e('Login timeout ke $baseUrl/login');
      return null;
    } catch (e) {
      _logger.e('Error login API: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await http
          .post(Uri.parse('$baseUrl/logout'), headers: await _jsonHeaders())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      _logger.w('Logout API failed: $e');
    } finally {
      await AuthStorage.clearSession();
    }
  }
}
