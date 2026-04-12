import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  static final Logger _logger = Logger();
  // GANTI '192.168.1.XX' dengan IP Laptop Anda yang muncul di ipconfig
  static const String baseUrl = 'http://192.168.1.8:8000/api';

  // Endpoint disesuaikan dengan Route::post('/sync-pelanggan') di Laravel tadi
  static const String endpoint = '$baseUrl/sync-pelanggan';

  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _logger.w('Login failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error login API: $e');
      return null;
    }
  }

  static Future<bool> savePelanggan(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            // Pastikan key sesuai dengan validasi Laravel
            body: jsonEncode({
              'nama': data['nama'],
              'alamat': data['alamat'],
              'no_meter':
                  data['id_pelanggan'] ??
                  data['no_meter'], // Support kedua format
              'daya_listrik': data['daya_listrik'],
              'no_hp': data['no_hp'],
              'foto_path':
                  data['foto_path'], // Untuk foto, kirim path atau base64
            }),
          )
          .timeout(const Duration(seconds: 10));

      return (response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      _logger.e('Error API: $e');
      return false;
    }
  }

  // Kirim batch data pelanggan
  static Future<List<int>> saveBatchPelanggan(
    List<Map<String, dynamic>> dataList,
  ) async {
    List<int> successfulIds = [];

    for (var data in dataList) {
      try {
        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(data),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 201) {
          successfulIds.add(data['id'] as int);
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
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
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
}
