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
        badgeColor = const Color(0xFF4CAF50);
        break;
      case 'sedang':
        badgeColor = const Color(0xFFFF9800);
        break;
      case 'berat':
        badgeColor = const Color(0xFFF44336);
        break;
      default:
        badgeColor = Colors.grey;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          level.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
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
      appBar: AppBar(
        title: const Text(
          "Pothole Reports",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent),
            onPressed: () => _confirmLogout(context),
            tooltip: "Logout",
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
              decoration: const InputDecoration(
                hintText: "Cari nama jalan...",
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
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
                            size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          "Tidak ada data laporan",
                          style: TextStyle(
                            color: Colors.grey,
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
                                    color: const Color(0xFF1C1C22),
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                          ),
                          title: Text(
                            item['jalan'] ?? 'Jalan Tidak Diketahui',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[850]!, width: 0.5),
                            ),
                            color: const Color(0xFF1C1C22),
                            elevation: 8,
                            onSelected: (value) async {
                              if (value == 'edit') {
                                bool? updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReportFormPage(report: item),
                                  ),
                                );
                                if (updated == true) refreshData();
                              } else if (value == 'delete') {
                                _confirmDelete(item['id'], item['jalan']);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 20, color: Color(0xFFFF9100)),
                                    SizedBox(width: 10),
                                    Text("Edit Laporan", style: TextStyle(color: Colors.white, fontSize: 14)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                    SizedBox(width: 10),
                                    Text("Hapus", style: TextStyle(color: Colors.white, fontSize: 14)),
                                  ],
                                ),
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
          FloatingActionButton.small(
            heroTag: "btnChat",
            backgroundColor: const Color(0xFF18181C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[850]!, width: 1),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
            child: const Icon(Icons.forum_outlined, color: Color(0xFFFF9100), size: 18),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "btnAdd",
            backgroundColor: const Color(0xFFFF9100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
