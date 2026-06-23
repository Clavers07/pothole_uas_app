import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://192.168.18.226:3000";
  final String baseUrlNlp = "http://192.168.18.226:8000";

  Future<Map<String, dynamic>> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/ping'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Koneksi berhasil.',
          'status': data['status'] ?? 'connected'
        };
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Gagal menghubungi database.',
            'status': data['status'] ?? 'error'
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'HTTP Status: ${response.statusCode}',
            'status': 'error'
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server di $baseUrl. Silakan periksa jaringan/IP Address Anda.',
        'status': 'offline'
      };
    }
  }

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

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
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

  Future<List> fetchReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  Future<void> deleteReport(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await http.delete(
      Uri.parse('$baseUrl/reports/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<bool> saveReport(String jalan, String levelKerusakan, File? image, {int? id}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // Menentukan metode dan URL berdasarkan ada tidaknya ID
    var request = http.MultipartRequest(
      id == null ? 'POST' : 'PUT',
      Uri.parse(id == null ? '$baseUrl/reports' : '$baseUrl/reports/$id'),
    );
    // Menambahkan Header Otorisasi
    request.headers['Authorization'] = 'Bearer $token';
    // Menambahkan Field Teks
    request.fields['jalan'] = jalan;
    request.fields['level_kerusakan'] = levelKerusakan;
    // Menggunakan http.MultipartFile.fromPath
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'pic',
          image.path,
          // note: tetap pertahankan MediaType lama demi logic asli
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );
    }
    // Mengirim permintaan
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode == 201 || response.statusCode == 200;
  }
}
