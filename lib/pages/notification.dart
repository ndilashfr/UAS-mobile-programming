import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Pastikan intl sudah ada di pubspec.yaml

// Navigasi
import 'leaderboard.dart';
import 'profile.dart'; // Sesuaikan jika nama file-mu profile_page.dart
import 'home.dart';
import 'create_challenge.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),

      // --- APP BAR BERSIH (TANPA TOMBOL TEST) ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // --- NAVIGASI BAWAH ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a, b) => const HomePage(),
                    transitionDuration: Duration.zero,
                  ),
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
            const SizedBox(width: 48),
            IconButton(
              // Ikon Putih karena sedang aktif
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
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

      // --- STREAM BUILDER (DATA NYATA) ---
      body: SafeArea(
        child: _user == null
            ? const Center(
                child: Text(
                  'Silakan login',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    // Filter: Hanya ambil notifikasi milik User yang sedang login
                    .where('userId', isEqualTo: _user!.uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Belum ada notifikasi.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // --- LOGIKA UI ---
                  final List<Map<String, dynamic>> todayItems = [];
                  final List<Map<String, dynamic>> yesterdayItems = [];

                  final now = DateTime.now();
                  final todayStart = DateTime(now.year, now.month, now.day);

                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final Timestamp? ts = data['createdAt'];

                    if (ts == null) continue;

                    final DateTime date = ts.toDate();

                    final itemMap = {
                      'icon': _getIconFromString(data['iconName']),
                      'color': _getColorFromString(data['colorName']),
                      'title': data['title'] ?? 'Tanpa Judul',
                      'subtitle': data['subtitle'] ?? '',
                      'time': _formatTime(ts),
                    };

                    if (date.isAfter(todayStart)) {
                      todayItems.add(itemMap);
                    } else {
                      yesterdayItems.add(itemMap);
                    }
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (todayItems.isNotEmpty)
                            _buildNotificationSection(
                              title: 'Hari ini',
                              items: todayItems,
                            ),

                          const SizedBox(height: 24),

                          if (yesterdayItems.isNotEmpty)
                            _buildNotificationSection(
                              title: 'Sebelumnya',
                              items: yesterdayItems,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildNotificationSection({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildNotificationItem(
              icon: item['icon'],
              iconColor: item['color'],
              title: item['title'],
              subtitle: item['subtitle'],
              time: item['time'],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- LOGIC HELPER (Sesuai data Firestore kamu) ---

  IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'task_alt':
        return Icons.task_alt;
      case 'person_add':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorFromString(String? colorName) {
    switch (colorName) {
      case 'yellow':
        return Colors.yellow.shade600;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(Timestamp ts) {
    final DateTime date = ts.toDate();
    return DateFormat.jm().format(date);
  }
}
