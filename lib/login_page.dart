import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isRedirecting = false;

  // State untuk status koneksi API
  bool _isCheckingConnection = false;
  bool? _isServerConnected;
  String _connectionMessage = "";

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    setState(() {
      _isCheckingConnection = true;
      _isServerConnected = null;
      _connectionMessage = "Memeriksa koneksi server...";
    });
    final result = await ApiService().checkConnection();
    if (!mounted) return;
    setState(() {
      _isCheckingConnection = false;
      _isServerConnected = result['success'];
      _connectionMessage = result['message'];
    });
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final token = await ApiService().login(
          emailController.text.trim(),
          passwordController.text,
        );
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (token != null) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email atau Password salah!"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal terhubung ke server: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> recognizeFaceAndLogin() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Kompres kualitas
      maxWidth: 800,    // Batasi resolusi agar upload & proses dlib sangat cepat
    );
    if (pickedFile == null) {
      _showErrorDialog("Tidak ada gambar yang dipilih.");
      return;
    }
    try {
      setState(() => _isLoading = true);
      // 1. Kirim gambar ke Flask untuk pengenalan wajah
      final faceRequest = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.18.226:5000/recognize-face'),
      );
      faceRequest.files.add(
        await http.MultipartFile.fromPath('image', pickedFile.path),
      );
      final faceResponse = await faceRequest.send();
      final faceBody = await faceResponse.stream.bytesToString();
      if (!mounted) return;
      if (faceResponse.statusCode != 200) {
        setState(() => _isLoading = false);
        _showErrorDialog("Wajah tidak dikenali. Silakan coba lagi.");
        return;
      }
      final faceJson = json.decode(faceBody);
      // Disarankan Flask mengirimkan field: face_label
      // Tetapi fallback ini tetap bisa membaca dari faces[0]['label']
      String? faceLabel;
      if (faceJson['face_label'] != null) {
        faceLabel = faceJson['face_label'].toString();
      } else if (faceJson['faces'] != null &&
          faceJson['faces'] is List &&
          faceJson['faces'].isNotEmpty &&
          faceJson['faces'][0]['label'] != null) {
        faceLabel = faceJson['faces'][0]['label'].toString();
      }
      if (faceLabel == null || faceLabel.isEmpty || faceLabel == "Unknown") {
        setState(() => _isLoading = false);
        _showErrorDialog("Wajah tidak dikenali oleh sistem.");
        return;
      }
      // 2. Kirim face_label ke Node.js agar Node.js yang membuat token aplikasi
      final nodeResponse = await http.post(
        Uri.parse('http://192.168.18.226:3000/login-face'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'face_label': faceLabel}),
      );
      if (!mounted) return;
      if (nodeResponse.statusCode == 200) {
        final nodeJson = json.decode(nodeResponse.body);
        final token = nodeJson['token'];
        if (token != null && token.toString().isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token.toString());
          if (!mounted) return;
          // 3. Tampilkan preloader sebelum masuk dashboard
          setState(() {
            _isLoading = false;
            _isRedirecting = true;
          });
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          setState(() => _isLoading = false);
          _showErrorDialog("Token dari server Node.js tidak ditemukan.");
        }
      } else {
        setState(() => _isLoading = false);
        String message = "Login wajah gagal di server Node.js.";
        try {
          final errorJson = json.decode(nodeResponse.body);
          if (errorJson['message'] != null) {
            message = errorJson['message'].toString();
          }
        } catch (_) {}
        _showErrorDialog(message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog("Terjadi kesalahan: $e");
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConnectionStatus() {
    Color bgColor;
    Color textColor;
    Color iconColor;
    IconData icon;
    String statusLabel;

    if (_isCheckingConnection) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade800;
      iconColor = Colors.blue.shade600;
      icon = Icons.sync;
      statusLabel = "Memeriksa koneksi...";
    } else if (_isServerConnected == true) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      iconColor = Colors.green.shade600;
      icon = Icons.check_circle_outline;
      statusLabel = "Server Terhubung";
    } else if (_isServerConnected == false) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      iconColor = Colors.red.shade600;
      icon = Icons.error_outline;
      statusLabel = "Koneksi Gagal";
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _isCheckingConnection
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                )
              : Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                if (_connectionMessage.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _connectionMessage,
                    style: TextStyle(
                      color: textColor.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!_isCheckingConnection)
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: iconColor, size: 20),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: _checkServer,
              tooltip: "Coba lagi",
            ),
        ],
      ),
    );
  }

  Widget _buildRedirectPreloader() {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Login berhasil, memuat halaman utama...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3880FF), Color(0xFF4C8DFF)],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.report_problem_rounded, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "POTHOLE REPORT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "Laporkan jalan berlubang di sekitarmu",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 40,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Selamat Datang",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222428),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Silakan login untuk melanjutkan",
                              style: TextStyle(color: Color(0xFF92949C)),
                            ),
                            const SizedBox(height: 16),
                            _buildConnectionStatus(),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "Email tidak boleh kosong"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "Password tidak boleh kosong"
                                  : null,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3DC2FF), // Ionic secondary
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: (_isLoading || _isRedirecting)
                                    ? null
                                    : recognizeFaceAndLogin,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "MASUK DENGAN PENGENALAN WAJAH",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3880FF), // Ionic primary
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: (_isLoading || _isRedirecting)
                                    ? null
                                    : _handleLogin,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "MASUK",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isRedirecting) _buildRedirectPreloader(),
        ],
      ),
    );
  }
}
