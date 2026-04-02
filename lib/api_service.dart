import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // GANTI '192.168.1.XX' dengan IP Laptop Anda yang muncul di ipconfig
  static const String baseUrl = 'http://192.168.1.8:8000/api';

  // Endpoint disesuaikan dengan Route::post('/sync-pelanggan') di Laravel tadi
  static const String endpoint = '$baseUrl/sync-pelanggan';

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
      print('Error API: $e');
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
        print('Error saat send batch: $e');
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
        print('Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error upload foto: $e');
      return null;
    }
  }
}
