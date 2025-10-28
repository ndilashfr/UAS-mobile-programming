import 'package:flutter/material.dart';
import 'leaderboard.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      // Bottom Navigation Bar Kustom (sama seperti halaman daily progress)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF007AFF),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF2C2C2E),
        shape: const CircularNotchedRectangle(), // <-- DITAMBAHKAN
        notchMargin: 8.0, // <-- DITAMBAHKAN
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.grey,
              ), // <-- WARNA DIUBAH
              onPressed: () {
                // Kembali ke halaman home
                // Navigator.pop(context); // Cukup pop sekali
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.bar_chart,
                color: Colors.grey,
              ), // <-- DITAMBAHKAN
              onPressed: () {
                // 2. Navigasi ke LeaderboardPage
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const LeaderboardPage(),
                    transitionDuration: Duration.zero, // Transisi instan
                  ),
                );
              },
            ),
            const SizedBox(width: 48), // <-- Spasi disamakan
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.grey,
              ), // <-- DITAMBAHKAN
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ), // <-- IKON & WARNA DIUBAH
              onPressed: () {
                // Sudah di halaman ini, tidak perlu aksi
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Gambar Profil
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://placehold.co/200x200/2C2C2E/FFFFFF?text=EB',
                  ), // Ganti dengan URL gambar
                ),
                const SizedBox(height: 16),
                // Nama dan Email
                const Text(
                  'Erlich Bachman',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'erlichbachman@piedpiper.com',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
                const SizedBox(height: 24),
                // Tombol Edit Profile
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Bagian Notifikasi
                _buildSectionTitle('Notifications'),
                _buildNotificationCard(),
                const SizedBox(height: 30),
                // Bagian Invite Link
                _buildSectionTitle('Invite Link'),
                _buildInviteCard(),
                const SizedBox(height: 30),
                // Tombol Log out
                TextButton(
                  onPressed: () {
                    // Gunakan pushAndRemoveUntil untuk kembali ke Login dan hapus semua halaman lain
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPages(),
                      ),
                      (Route<dynamic> route) =>
                          false, // false berarti "hapus semua rute sebelumnya"
                    );
                  },
                  child: Text(
                    'Log out',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk judul bagian
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
        child: Text(
          title,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        ),
      ),
    );
  }

  // Widget untuk kartu notifikasi
  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Turn on Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeTrackColor: const Color(0xFF007AFF),
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // Widget untuk kartu invite
  Widget _buildInviteCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Invite people',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: const Text(
              'Invite',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
