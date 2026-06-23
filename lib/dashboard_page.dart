import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'report_form_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List allReports = [];
  List filteredReports = [];
  TextEditingController searchController = TextEditingController();

  void refreshData() async {
    final data = await ApiService().fetchReports();
    setState(() {
      allReports = data;
      filteredReports = data;
    });
  }

  void filterData(String query) {
    setState(() {
      filteredReports = allReports
          .where(
            (item) =>
                item['jalan'].toString().toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Logout"),
        content: const Text("Apakah yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF92949C))),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              if (!mounted) return;
              if (!dialogCtx.mounted) return;
              Navigator.pop(dialogCtx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Berhasil keluar")),
              );
            },
            child: const Text("Keluar", style: TextStyle(color: Color(0xFFEB445A))),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id, String namaJalan) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Konfirmasi Hapus"),
        content: Text("Apakah yakin ingin menghapus data '$namaJalan'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF92949C))),
          ),
          TextButton(
            onPressed: () async {
              await ApiService().deleteReport(id);
              if (!mounted) return;
              if (!dialogCtx.mounted) return;
              Navigator.pop(dialogCtx);
              refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data berhasil dihapus"),
                  backgroundColor: Color(0xFFEB445A),
                ),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Color(0xFFEB445A))),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(String level) {
    Color badgeColor;
    switch (level.toLowerCase()) {
      case 'ringan':
        badgeColor = const Color(0xFF2DD36F); // Ionic success (green)
        break;
      case 'sedang':
        badgeColor = const Color(0xFFFFC409); // Ionic warning (yellow/orange)
        break;
      case 'berat':
        badgeColor = const Color(0xFFEB445A); // Ionic danger (red)
        break;
      default:
        badgeColor = const Color(0xFF92949C); // Ionic medium (grey)
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: const Text(
          "Pothole Reports",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEB445A)),
            onPressed: () => _confirmLogout(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: filterData,
              decoration: const InputDecoration(
                hintText: "Cari nama jalan...",
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF92949C)),
              ),
            ),
          ),
          Expanded(
            child: filteredReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.report_problem_outlined,
                            size: 64, color: const Color(0xFF92949C).withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          "Tidak ada data laporan",
                          style: TextStyle(
                            color: Color(0xFF92949C),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final item = filteredReports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item['pic'] != null
                                ? Image.network(
                                    "http://192.168.18.226:3000/uploads/${item['pic']}",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: const Color(0xFFFFC409).withOpacity(0.15),
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFFFC409),
                                      size: 32,
                                    ),
                                  ),
                          ),
                          title: Text(
                            item['jalan'] ?? 'Jalan Tidak Diketahui',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF222428),
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildLevelBadge(
                                  item['level_kerusakan'] ?? 'unknown'),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF3880FF), // Ionic primary
                                ),
                                onPressed: () async {
                                  bool? updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReportFormPage(report: item),
                                    ),
                                  );
                                  if (updated == true) refreshData();
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFEB445A), // Ionic danger
                                ),
                                onPressed: () =>
                                    _confirmDelete(item['id'], item['jalan']),
                              ),
                            ],
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
          // Tombol Chatbot NLP (Ionic secondary color)
          FloatingActionButton.small(
            heroTag: "btnChat",
            backgroundColor: const Color(0xFF3DC2FF),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
            child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
          ),
          const SizedBox(height: 12),
          // Tombol Tambah Report (Ionic primary color)
          FloatingActionButton(
            heroTag: "btnAdd",
            backgroundColor: const Color(0xFF3880FF),
            onPressed: () async {
              bool? added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportFormPage()),
              );
              if (added == true) refreshData();
            },
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
