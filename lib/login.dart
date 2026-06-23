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

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> recognizeFaceAndLogin() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile == null) {
      _showErrorDialog("Tidak ada gambar yang dipilih.");
      return;
    }

    try {
      setState(() => _isLoading = true);

      final faceRequest = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.18.12:5000/recognize-face'),
      );

      faceRequest.files.add(
        await http.MultipartFile.fromPath(
          'image',
          pickedFile.path,
        ),
      );

      final faceResponse = await faceRequest.send();
      final faceBody = await faceResponse.stream.bytesToString();

      if (!mounted) return;

      if (faceResponse.statusCode != 200) {
        setState(() => _isLoading = false);
        _showErrorDialog("Wajah tidak dikenali.");
        return;
      }

      final faceJson = json.decode(faceBody);

      String? faceLabel;

      if (faceJson['face_label'] != null) {
        faceLabel = faceJson['face_label'];
      }

      if (faceLabel == null || faceLabel == "Unknown") {
        setState(() => _isLoading = false);
        _showErrorDialog("Wajah tidak dikenali.");
        return;
      }

      final nodeResponse = await http.post(
        Uri.parse('http://192.168.18.12:3000/login-face'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'face_label': faceLabel}),
      );

      if (nodeResponse.statusCode == 200) {
        final data = json.decode(nodeResponse.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        setState(() {
          _isLoading = false;
          _isRedirecting = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() => _isLoading = false);
        _showErrorDialog("Login wajah gagal.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildRedirectPreloader() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 15),
            Text(
              "Login berhasil...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
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
                colors: [
                  Color(0xFF424242),
                  Color(0xFF757575),
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 80),

                const Icon(
                  Icons.add_road,
                  size: 90,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                const Text(
                  "JALAN BERLUBANG",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Aplikasi Pelaporan Kerusakan Jalan",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Text(
                              "Login Pengguna",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 30),

                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            TextFormField(
                              controller: passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible =
                                          !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.face),
                                label: const Text(
                                  "LOGIN WAJAH",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepOrange,
                                  foregroundColor:
                                      Colors.white,
                                ),
                                onPressed: recognizeFaceAndLogin,
                              ),
                            ),

                            const SizedBox(height: 15),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.brown,
                                  foregroundColor:
                                      Colors.white,
                                ),
                                child: const Text(
                                  "MASUK",
                                  style: TextStyle(
                                    fontSize: 18,
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

          if (_isRedirecting)
            _buildRedirectPreloader(),
        ],
      ),
    );
  }
}