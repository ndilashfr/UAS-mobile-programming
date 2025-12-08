// Lokasi: lib/overview_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewPage extends StatelessWidget {
  final User? user;
  final Stream<DocumentSnapshot>? userStream;

  const OverviewPage({super.key, required this.user, required this.userStream});

  @override
  Widget build(BuildContext context) {
    // Kita gunakan SingleChildScrollView agar bisa di-scroll
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. BAGIAN STATISTIK TOTAL ---
          _buildSectionHeader('Statistik Total'),
          const SizedBox(height: 16),
          _buildTotalStats(), // Panggil StreamBuilder baru
          const SizedBox(height: 30),

          // --- 2. BAGIAN GRAFIK (Placeholder) ---
          _buildSectionHeader('Grafik Poin (Coming Soon)'),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.bar_chart, color: Colors.grey, size: 50),
            ),
          ),
          const SizedBox(height: 30),

          // --- 3. BAGIAN KALENDER (Placeholder) ---
          _buildSectionHeader('Kalender Aktivitas (Coming Soon)'),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BARU UNTUK STREAM STATISTIK ---
  Widget _buildTotalStats() {
    // Tampilkan apa-apa jika user tidak login
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      // Ambil SEMUA dokumen partisipan milik user ini
      stream: FirebaseFirestore.instance
          .collection('participants')
          .where('userId', isEqualTo: user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Tampilkan loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle jika tidak ada data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Mulai sebuah challenge untuk melihat statistik.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // --- INTI LOGIKA KALKULASI ---
        int totalChallengesFinished = 0;
        int totalCheckInDays = 0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};

          final progress = (data['progress'] as num? ?? 0).toInt();
final duration = (data['challengeDuration'] as num? ?? 1)
    .toInt(); // Pakai data yg sudah ada// Pakai data yg sudah ada

          // 1. Hitung total hari check-in
          totalCheckInDays += progress;

          // 2. Hitung challenge selesai
          if (progress >= duration) {
            totalChallengesFinished++;
          }
        }
        // --- BATAS KALKULASI ---

        // Tampilkan dalam Grid
        return GridView.count(
          crossAxisCount: 2, // 2 kolom
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.5, // Atur rasio kartu
          children: [
            // Kartu 1: Total Selesai
            _buildStatCard(
              icon: Icons.emoji_events_outlined,
              value: totalChallengesFinished.toString(),
              label: 'Challenge Selesai',
              color: Colors.yellowAccent,
            ),

            // Kartu 2: Total Check-in
            _buildStatCard(
              icon: Icons.check_circle_outline,
              value: totalCheckInDays.toString(),
              label: 'Total Check-in',
              color: Colors.greenAccent,
            ),

            // Kartu 3: Rangkaian (Streak)
            // Kita belum bisa hitung ini karena data tidak lengkap
            _buildStatCard(
              icon: Icons.local_fire_department_outlined,
              value: 'N/A', // Tulis N/A (Not Available)
              label: 'Rangkaian Hari',
              color: Colors.orangeAccent,
            ),
          ],
        );
      },
    );
  }

  // --- HELPER UNTUK KARTU STATISTIK ---
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- HELPER UNTUK JUDUL ---
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
