import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'sampah_form_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List allJalan = [];
  List filteredJalan = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final data = await ApiService().fetchJalan();

    setState(() {
      allJalan = data;
      filteredJalan = data;
    });
  }

  void filterData(String query) {
    setState(() {
      filteredJalan = allJalan.where((item) {
        return item['nama_jalan']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text(
          "Apakah yakin ingin keluar dari aplikasi?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              final prefs =
                  await SharedPreferences.getInstance();

              await prefs.remove('token');

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
            child: const Text(
              "Keluar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id, String namaJalan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text(
          "Apakah yakin ingin menghapus laporan '$namaJalan' ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await ApiService().deleteJalan(id);

              Navigator.pop(context);

              refreshData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Laporan berhasil dihapus",
                  ),
                ),
              );
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "Pelaporan Jalan Berlubang",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: filterData,
              decoration: InputDecoration(
                hintText: "Cari nama jalan...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: filteredJalan.length,
              itemBuilder: (context, index) {

                final item = filteredJalan[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),

                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(10),

                    leading: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),

                      child: item['foto'] != null
                          ? Image.network(
                              item['foto_url'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.orange[100],
                              child: const Icon(
                                Icons.add_road,
                                color: Colors.orange,
                              ),
                            ),
                    ),

                    title: Text(
                      item['nama_jalan'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "Tingkat Kerusakan : ${item['tingkat_kerusakan']}",
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _confirmDelete(
                        item['id'],
                        item['nama_jalan'],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          FloatingActionButton.small(
            heroTag: "chat",

            backgroundColor: Colors.blue,

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatPage(),
                ),
              );
            },

            child: const Icon(
              Icons.chat,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "add",

            backgroundColor: Colors.orange,

            onPressed: () async {

              bool? added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SampahFormPage(),
                ),
              );

              if (added == true) {
                refreshData();
              }
            },

            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}