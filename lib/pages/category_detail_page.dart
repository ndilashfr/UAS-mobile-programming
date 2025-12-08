import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:community_challenge_app/pages/challenge_detail_page.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryName;

  const CategoryDetailPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('challenges')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada challenge di kategori "$categoryName".',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final challenges = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challengeDoc = challenges[index];
              final data = challengeDoc.data() as Map<String, dynamic>;

              return _buildChallengeCard(
                context: context,
                data: data,
                challengeId: challengeDoc.id,
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGET KARTU CHALLENGE (TANPA PROGRESS BAR) ---
  Widget _buildChallengeCard({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String challengeId,
  }) {
    final String title = data['title'] ?? 'Tanpa Judul';
    final String category = data['category'] ?? 'Lainnya';
    final int duration = data['duration'] ?? 1;
    final int members = data['members'] ?? 0;

    final IconData icon = _getIconForCategory(category);
    final Color color = _getColorForCategory(category);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeDetailPage(
              challengeId: challengeId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)), // Sedikit border biar rapi
        ),
        child: Row(
          children: [
            // Ikon Kategori
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Info Challenge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Info Tambahan (Durasi & Member)
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        "$duration hari",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.people, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        "$members peserta",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tombol Panah
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER ICON & COLOR ---
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ibadah': return Icons.mosque_outlined;
      case 'kesehatan': return Icons.directions_run_outlined;
      case 'produktifitas': return Icons.lightbulb_outline;
      case 'alquran': case 'quran': return Icons.book_outlined;
      case 'sedekah': case 'donation': return Icons.volunteer_activism_outlined;
      case 'work': return Icons.work_outline;
      case 'reminder': return Icons.notifications_none_outlined;
      case 'reading': return Icons.menu_book_outlined;
      case 'study': return Icons.school_outlined;
      default: return Icons.category_outlined;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ibadah': return Colors.lightGreenAccent;
      case 'kesehatan': return Colors.redAccent;
      case 'produktifitas': return Colors.yellowAccent;
      case 'alquran': case 'quran': return Colors.blueAccent;
      case 'sedekah': case 'donation': return Colors.orangeAccent;
      case 'work': return Colors.purpleAccent;
      case 'reminder': return Colors.greenAccent;
      case 'study': return Colors.tealAccent;
      default: return Colors.grey;
    }
  }
}