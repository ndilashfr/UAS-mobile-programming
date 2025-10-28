import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // <-- 1. IMPORT PAKET
import 'home.dart'; // Untuk Navigasi
import 'leaderboard.dart'; // Untuk Navigasi
import 'notification.dart'; // Untuk Navigasi
import 'profile.dart'; // Untuk Navigasi
import 'create_challenge.dart'; // Untuk Navigasi FAB

// 2. UBAH JADI STATEFULWIDGET
class DailyProgressPage extends StatefulWidget {
  const DailyProgressPage({super.key});

  @override
  State<DailyProgressPage> createState() => _DailyProgressPageState();
}

class _DailyProgressPageState extends State<DailyProgressPage> {
  // 3. PINDAHKAN DATA TASK KE STATE
  final List<Map<String, dynamic>> _tasks = [
    {'icon': Icons.menu_book, 'color': Colors.blue, 'title': 'Khatam Juz 29'},
    {
      'icon': Icons.notifications_active_outlined,
      'color': Colors.green,
      'title': 'Sholat Tahajud selama 30 hari ',
    },
    {
      'icon': Icons.check_circle,
      'color': Colors.purple,
      'title': 'Journaling Harian selama 7 hari',
    },
    {
      'icon': Icons.reply,
      'color': Colors.orange,
      'title': 'Sharing Positive Quotes',
    },
  ];

  // Fungsi untuk delete
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    // Tampilkan snackbar konfirmasi (opsional)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tugas telah dihapus'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Fungsi untuk edit (placeholder)
  void _editTask(int index) {
    // Di sini Anda bisa menampilkan dialog atau halaman baru untuk mengedit
    print('Edit task: ${_tasks[index]['title']}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fungsi Edit Dipanggil'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      // Bottom Navigation Bar Kustom (DIPERBAIKI AGAR KONSISTEN)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke Create Challenge Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateChallengePage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF007AFF),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF2C2C2E),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.grey),
              onPressed: () {
                // Kembali ke halaman home (asumsi HomePage adalah rute utama)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.grey),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a, b) => const LeaderboardPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            const SizedBox(width: 48), // Spasi untuk FAB
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.grey),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a, b) => const NotificationPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a, b) => const ProfilePage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar Kustom
              _buildAppBar(context),
              const SizedBox(height: 24),

              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 24),

              // Tombol Filter
              _buildFilterTabs(),
              const SizedBox(height: 30),

              // 4. GANTI DENGAN LISTVIEW.BUILDER
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    // Kirim index ke _buildTaskItem
                    return _buildTaskItem(
                      icon: task['icon'],
                      color: task['color'],
                      title: task['title'],
                      index: index, // Kirim index untuk aksi delete/edit
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Widget _buildAppBar, _buildSearchBar, _buildFilterTabs tetap sama) ...
  Widget _buildAppBar(BuildContext context) {
    // ... (kode _buildAppBar Anda tidak berubah)
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          // Judul
          const Text(
            'Daily progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Ikon kanan
          Row(
            children: [
              const Icon(Icons.search, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://placehold.co/100x100/2C2C2E/FFFFFF?text=EB',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    // ... (kode _buildSearchBar Anda tidak berubah)
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildFilterTabs() {
    // ... (kode _buildFilterTabs Anda tidak berubah)
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'All',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(width: 15),
        TextButton(
          onPressed: () {},
          child: Text(
            'Favorite',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ),
      ],
    );
  }

  // 5. MODIFIKASI _buildTaskItem DENGAN SLIDABLE
  Widget _buildTaskItem({
    required IconData icon,
    required Color color,
    required String title,
    required int index, // Terima index
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Slidable(
        // Kunci unik untuk setiap item, penting untuk performa
        key: ValueKey(title),

        // Aksi geser dari kanan ke kiri (endActionPane)
        endActionPane: ActionPane(
          motion: const StretchMotion(), // Efek geser
          children: [
            // Tombol Edit
            SlidableAction(
              onPressed: (context) {
                _editTask(index);
              },
              backgroundColor: const Color(0xFF007AFF), // Warna biru
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(20),
            ),
            // Tombol Delete
            SlidableAction(
              onPressed: (context) {
                _deleteTask(index);
              },
              backgroundColor: const Color(0xFFFE3B30), // Warna merah
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Delete',
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),

        // Ini adalah widget item Anda yang asli
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
