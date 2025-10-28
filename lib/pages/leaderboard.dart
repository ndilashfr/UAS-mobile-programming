import 'package:flutter/material.dart';
import 'profile.dart'; // Impor untuk navigasi
import 'notification.dart'; // <-- TAMBAHKAN IMPOR INI
import 'create_challenge.dart'; // <-- TAMBAHKAN IMPOR INI

// 1. Ubah menjadi StatefulWidget
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // 2. Ubah state untuk dropdown menjadi List<Map>
  final List<Map<String, dynamic>> _challengeOptions = [
    {
      'text': 'Tilawah Al-Quran Harian',
      'icon': Icons.menu_book,
    },
    {
      'text': 'Daily Productivity Task',
      'icon': Icons.check_circle_outline, // Ikon baru
    },
    {
      'text': 'Weekly Reading Goal',
      'icon': Icons.bookmark_border_rounded, // Ikon baru
    },
  ];
  // Ganti state dari String menjadi Map
  late Map<String, dynamic> _selectedChallenge;

  @override
  void initState() {
    super.initState();
    // Inisialisasi state
    _selectedChallenge = _challengeOptions[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      // ... (Bottom Navigation Bar & FAB tetap sama) ...
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // <-- UBAH INI
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateChallengePage()),
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
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              onPressed: () {},
            ),
            const SizedBox(width: 48), // Spasi untuk FAB
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.grey),
              onPressed: () {
                // <-- UBAH INI
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const NotificationPage(),
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
                    pageBuilder: (context, animation1, animation2) =>
                        const ProfilePage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                _buildAppBar(context),
                const SizedBox(height: 24),
                _buildChallengeDropdown(), // Panggil widget dropdown yang sudah diperbarui
                const SizedBox(height: 30),
                _buildPodium(), // Panggil widget podium yang sudah diperbarui
                const SizedBox(height: 30),
                _buildRankItem(
                    rank: 4,
                    name: 'Siti Nurhaliza',
                    details: '26/30 hari',
                    points: '275',
                    isUp: true),
                _buildRankItem(
                    rank: 5,
                    name: 'Erlich Bachman (Anda)',
                    details: '25/30 hari',
                    points: '268',
                    isUser: true,
                    isUp: false),
                _buildRankItem(
                    rank: 6,
                    name: 'Zahra Kamila',
                    details: '24/30 hari',
                    points: '252'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (_buildAppBar tetap sama) ...
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        // 1. Ganti alignment menjadi center
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2. Hapus Tombol Kiri (GestureDetector)
          /*
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
            ),
          ),
          */

          // Bagian Judul (Tetap)
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.yellow.shade600, size: 28),
              const SizedBox(width: 8),
              const Text('Leaderboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),

          // 3. Hapus Tombol Kanan (Container)
          /*
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
          */
          // AKHIR DARI BAGIAN YANG HILANG
        ],
      ),
    );
  } // <--- TAMBAHKAN KURUNG KURAWAL PENUTUP INI

  // 3. Ubah _buildChallengeDropdown (VERSI PERBAIKAN)
  Widget _buildChallengeDropdown() {
    // GANTI Row dengan Align agar tidak error layout
    return Align(
      alignment: Alignment.centerLeft, // Posisikan di kiri
      child: Container(
        // Kita bungkus dengan Container agar bisa memberi padding & dekorasi
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedChallenge,
          items: _challengeOptions.map((Map<String, dynamic> option) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: option,
              // Ini adalah tampilan item di dalam MENU
              child: Row(
                children: [
                  Icon(option['icon'] as IconData,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    option['text'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ), // <- Kurung tutup Text
                ],
              ), // <- Kurung tutup Row
            ); // <- Kurung tutup DropdownMenuItem
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedChallenge = newValue!;
            });
          },
          // Ini adalah tampilan item saat TERPILIH (di "tombol")
          selectedItemBuilder: (BuildContext context) {
            return _challengeOptions.map((Map<String, dynamic> option) {
              return Row(
                children: [
                  Icon(option['icon'] as IconData,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    option['text'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          // Styling
          decoration: InputDecoration(
            // Hapus prefixIcon, karena sudah kita tambahkan manual di builder
            // Beri padding agar icon & text tidak mepet ke kiri
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: InputBorder.none, // Hapus border bawaan
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          icon: const Icon(Icons.arrow_drop_down,
              color: Colors.white), // Ikon panah
          dropdownColor: const Color(0xFF2C2C2E), // Warna background menu
          // ----------------------------------------------------
          menuMaxHeight:
              200, // Opsional: Batasi tinggi menu jika terlalu banyak item
        ),
      ),
    );
  }

  // 4. Perbaiki _buildPodium dengan Expanded
  Widget _buildPodium() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bungkus setiap anggota podium dengan Expanded
        Expanded(
          child: _buildPodiumMember(
            rank: 2,
            name: 'Fatimah Azzahra',
            points: '295 pts',
            picUrl: 'https://placehold.co/100x100/4A90E2/FFFFFF?text=FA',
            borderColor: Colors.grey.shade400,
          ),
        ),
        Expanded(
          child: _buildPodiumMember(
            rank: 1,
            name: 'Ahmad Ridho',
            points: '298 pts',
            picUrl: 'https://placehold.co/100x100/F5A623/FFFFFF?text=AR',
            borderColor: Colors.yellow.shade600,
            isWinner: true,
          ),
        ),
        Expanded(
          child: _buildPodiumMember(
            rank: 3,
            name: 'Muhammad Ilham',
            points: '287 pts',
            picUrl: 'https://placehold.co/100x100/D0021B/FFFFFF?text=MI',
            borderColor: Colors.brown.shade400,
          ),
        ),
      ],
    );
  }

  // ... (_buildPodiumMember dan _buildRankItem tetap sama) ...
  Widget _buildPodiumMember({
    required int rank,
    required String name,
    required String points,
    required String picUrl,
    required Color borderColor,
    bool isWinner = false,
  }) {
    double avatarRadius = isWinner ? 50 : 40;
    double verticalPadding = isWinner ? 0 : 20;

    // Hapus padding horizontal dari sini agar Expanded bisa bekerja
    return Padding(
      padding: EdgeInsets.only(bottom: verticalPadding),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: isWinner
                      ? [
                          BoxShadow(
                            color: borderColor.withOpacity(0.7),
                            blurRadius: 15,
                            spreadRadius: 3,
                          )
                        ]
                      : [],
                ),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: NetworkImage(picUrl),
                ),
              ),
              if (isWinner)
                Positioned(
                  top: -25,
                  left: 0,
                  right: 0,
                  child: Icon(Icons.emoji_events,
                      color: Colors.yellow.shade600, size: 30),
                ),
              Positioned(
                bottom: -10,
                left: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: borderColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(name,
              textAlign: TextAlign.center, // Tambahkan text align center
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(points,
              style: TextStyle(
                  color: Colors.blue.shade300,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRankItem({
    required int rank,
    required String name,
    required String details,
    required String points,
    bool isUser = false,
    bool? isUp,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUser
            ? const Color(0xFF007AFF).withOpacity(0.15)
            : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        border: isUser
            ? Border.all(color: const Color(0xFF007AFF), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 20,
            backgroundImage:
                NetworkImage('https://placehold.co/100x100/555555/FFFFFF?text=S'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  details,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: TextStyle(
                color: isUser ? Colors.white : Colors.blue.shade300,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          if (isUp != null)
            Icon(
              isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isUp ? Colors.green : Colors.red,
              size: 24,
            ),
        ],
      ),
    );
  }
}

