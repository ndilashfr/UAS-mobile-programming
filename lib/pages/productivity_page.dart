// Lokasi: lib/overview_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_challenge_list.dart'; // Impor yang dibutuhkan
import 'category_detail_page.dart'; // Impor yang dibutuhkan

class ProductivityPage extends StatelessWidget {
  // Terima data user yang dikirim dari home_page.dart
  final User? user;
  final Stream<DocumentSnapshot>? userStream;

  const ProductivityPage({
    super.key,
    required this.user,
    required this.userStream,
  });

  @override
  Widget build(BuildContext context) {
    // Kita gunakan SingleChildScrollView di sini
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Kartu Daily Progress
          _buildDailyProgressCard(context),
          const SizedBox(height: 30),

          // 2. Judul Categories
          const Text(
            'Categories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 3. Grid untuk Kategori (StreamBuilder)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('categories')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Terjadi kesalahan.'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Belum ada kategori.'));
              }

              final categories = snapshot.data!.docs;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1 / 1.0,
                ),
                itemCount: categories.length,
                shrinkWrap:
                    true, // Penting untuk di dalam SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Penting
                itemBuilder: (context, index) {
                  final categoryDoc = categories[index];
                  final data = categoryDoc.data() as Map<String, dynamic>;

                  final categoryName = data['name'] ?? 'Tanpa Nama';
                  final iconString = data['icon'] ?? 'default';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoryDetailPage(categoryName: categoryName),
                        ),
                      );
                    },
                    child: _buildCategoryCard(
                      icon: _getIconForCategory(iconString),
                      iconColor: _getColorForCategory(iconString),
                      categoryName: categoryName,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // --- SEMUA FUNGSI HELPER DIPINDAH KE SINI ---

  Widget _buildDailyProgressCard(BuildContext context) {
    if (user == null) {
      return _buildProgressCardUI(
        context: context,
        progressValue: 0.0,
        percentText: '0%',
        avatars: [],
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('participants')
          .where('userId', isEqualTo: user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildProgressCardUI(
            context: context,
            progressValue: 0.0,
            percentText: '...%',
            avatars: [],
          );
        }
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return _buildProgressCardUI(
            context: context,
            progressValue: 0.0,
            percentText: '0%',
            avatars: [],
          );
        }
        final participantDocs = snapshot.data!.docs;
        double totalUserProgress = 0;
        double totalPossibleProgress = 0;
        List<String> photoUrls = [];
        for (var doc in participantDocs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          totalUserProgress += (data['progress'] ?? 0);
          totalPossibleProgress += (data['challengeDuration'] ?? 1);
          if (photoUrls.length < 2 && data['photoUrl'] != null) {
            photoUrls.add(data['photoUrl']);
          }
        }
        double progressValue = 0.0;
        if (totalPossibleProgress > 0) {
          progressValue = totalUserProgress / totalPossibleProgress;
        }
        progressValue = progressValue.clamp(0.0, 1.0);
        String progressPercent = (progressValue * 100).toStringAsFixed(0);
        return _buildProgressCardUI(
          context: context,
          progressValue: progressValue,
          percentText: '$progressPercent%',
          avatars: photoUrls,
        );
      },
    );
  }

  Widget _buildProgressCardUI({
    required BuildContext context,
    required double progressValue,
    required String percentText,
    required List<String> avatars,
  }) {
    List<Widget> avatarStack = [];
    if (avatars.isNotEmpty) {
      avatarStack.add(
        CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(avatars[0]),
          backgroundColor: Colors.blue,
        ),
      );
    }
    if (avatars.length > 1) {
      avatarStack.add(
        Positioned(
          left: 15,
          child: CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(avatars[1]),
            backgroundColor: Colors.red,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyChallengeListPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Here you can see your daily task',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(width: 60, child: Stack(children: avatarStack)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              percentText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey.shade700,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF007AFF),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required Color iconColor,
    required String categoryName,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          const Spacer(),
          Text(
            categoryName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ibadah':
        return Icons.mosque_outlined;
      case 'kesehatan':
        return Icons.directions_run_outlined;
      case 'produktifitas':
        return Icons.lightbulb_outline;
      case 'alquran':
      case 'quran':
        return Icons.book_outlined;
      case 'sedekah':
      case 'donation':
        return Icons.volunteer_activism_outlined;
      case 'work':
        return Icons.work_outline;
      case 'reminder':
        return Icons.notifications_none_outlined;
      case 'reading':
        return Icons.menu_book_outlined;
      case 'study':
        return Icons.school_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ibadah':
        return Colors.lightGreenAccent;
      case 'kesehatan':
        return Colors.redAccent;
      case 'produktifitas':
        return Colors.yellowAccent;
      case 'alquran':
      case 'quran':
        return Colors.blueAccent;
      case 'sedekah':
      case 'donation':
        return Colors.orangeAccent;
      case 'work':
        return Colors.purpleAccent;
      case 'reminder':
        return Colors.greenAccent;
      case 'study':
        return Colors.tealAccent;
      default:
        return Colors.grey;
    }
  }
}
