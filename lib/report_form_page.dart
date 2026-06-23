import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class ReportFormPage extends StatefulWidget {
  final Map? report; // Null jika insert, ada isi jika update
  const ReportFormPage({super.key, this.report});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _jalanController = TextEditingController();
  String? _selectedLevel;
  File? _image;
  final ImagePicker _picker = ImagePicker(); // Inisialisasi library

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _jalanController.text = widget.report!['jalan'] ?? '';
      _selectedLevel = widget.report!['level_kerusakan'];
    }
  }

  Future<void> _pickImage() async {
    try {
      // Membuka galeri untuk memilih gambar
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Mengurangi kualitas agar ukuran file tidak terlalu besar
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // Menyimpan file ke variabel _image
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Menampilkan pesan jika terjadi error saat membuka galeri
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil gambar: $e")),
      );
    }
  }

  @override
  void dispose() {
    _jalanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? "Tambah Laporan" : "Edit Laporan"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Jalan Berlubang",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF222428)),
              ),
              const SizedBox(height: 20),
              
              // ═══ Input: Nama Jalan ═══
              TextFormField(
                controller: _jalanController,
                decoration: const InputDecoration(
                  labelText: "Nama Jalan",
                  prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF92949C)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama jalan harus diisi" : null,
              ),
              const SizedBox(height: 20),

              // ═══ Input: Level Kerusakan (Dropdown) ═══
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: "Level Kerusakan",
                  prefixIcon: Icon(Icons.speed_rounded, color: Color(0xFF92949C)),
                ),
                items: const [
                  DropdownMenuItem(value: "Ringan", child: Text("Ringan")),
                  DropdownMenuItem(value: "Sedang", child: Text("Sedang")),
                  DropdownMenuItem(value: "Berat", child: Text("Berat")),
                ],
                validator: (value) =>
                    value == null || value.isEmpty ? "Level kerusakan harus dipilih" : null,
                onChanged: (val) => setState(() => _selectedLevel = val),
              ),
              const SizedBox(height: 20),

              const Text(
                "Foto Kerusakan",
                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF222428)),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: Color(0xFF92949C),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Ketuk untuk memilih foto",
                              style: TextStyle(color: Color(0xFF92949C), fontSize: 14),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await ApiService().saveReport(
                        _jalanController.text,
                        _selectedLevel!,
                        _image,
                        id: widget.report?['id'],
                      );
                      if (success) {
                        if (!context.mounted) return;
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Laporan berhasil disimpan")),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "SIMPAN LAPORAN",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
