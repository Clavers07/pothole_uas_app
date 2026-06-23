import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  final String baseUrl = "http://192.168.18.226:3000";
  final String baseUrlNlp = "http://192.168.18.226:8000";

  // ================= CHATBOT =================

  Future<String> askChatbot(String message) async {

    try {

      final response = await http.post(
        Uri.parse('$baseUrlNlp/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        return data['response'];

      } else {

        return "Maaf, server sedang sibuk.";

      }

    } catch (e) {

      return "Gagal terhubung ke chatbot.";

    }

  }

  // ================= LOGIN =================

  Future<String?> login(String email, String password) async {

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', token);

      return token;

    }

    return null;

  }

  // ================= AMBIL DATA JALAN =================

  Future<List<dynamic>> fetchJalan() async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/jalan'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    } else {

      throw Exception("Gagal mengambil data");

    }

  }

  // ================= SIMPAN LAPORAN =================

  Future<bool> saveJalan(
    String namaJalan,
    String tingkatKerusakan,
    File? foto,
  ) async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/jalan'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['nama_jalan'] = namaJalan;
    request.fields['tingkat_kerusakan'] = tingkatKerusakan;

    if (foto != null) {

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          foto.path,
        ),
      );

    }

    final response = await request.send();

    return response.statusCode == 201 ||
        response.statusCode == 200;

  }

  // ================= HAPUS LAPORAN =================

  Future<void> deleteJalan(int id) async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('$baseUrl/jalan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {

      throw Exception("Gagal menghapus data");

    }

  }

  // ================= LOGOUT =================

  Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');

  }

}