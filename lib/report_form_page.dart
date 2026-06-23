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

  Widget _buildDamageLevelOption({
    required String level,
    required Color selectedColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.1) : const Color(0xFF18181C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey[850]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          level,
          style: TextStyle(
            color: isSelected ? selectedColor : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              
              // ═══ Input: Nama Jalan ═══
              TextFormField(
                controller: _jalanController,
                decoration: const InputDecoration(
                  labelText: "Nama Jalan",
                  prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama jalan harus diisi" : null,
              ),
              const SizedBox(height: 24),

              // ═══ Input: Level Kerusakan (Custom Selectors) ═══
              FormField<String>(
                initialValue: _selectedLevel,
                validator: (value) =>
                    value == null || value.isEmpty ? "Level kerusakan harus dipilih" : null,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.speed_rounded, color: Colors.grey, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "Level Kerusakan",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDamageLevelOption(
                              level: "Ringan",
                              selectedColor: const Color(0xFF4CAF50),
                              isSelected: state.value == "Ringan",
                              onTap: () {
                                setState(() => _selectedLevel = "Ringan");
                                state.didChange("Ringan");
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDamageLevelOption(
                              level: "Sedang",
                              selectedColor: const Color(0xFFFF9800),
                              isSelected: state.value == "Sedang",
                              onTap: () {
                                setState(() => _selectedLevel = "Sedang");
                                state.didChange("Sedang");
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDamageLevelOption(
                              level: "Berat",
                              selectedColor: const Color(0xFFF44336),
                              isSelected: state.value == "Berat",
                              onTap: () {
                                setState(() => _selectedLevel = "Berat");
                                state.didChange("Berat");
                              },
                            ),
                          ),
                        ],
                      ),
                      if (state.hasError) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            state.errorText!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                          ),
                        ),
                      ]
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                "Foto Kerusakan",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[850]!),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Ketuk untuk memilih foto",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
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
                    style: TextStyle(
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
    );
  }
}
