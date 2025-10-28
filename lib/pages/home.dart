import 'package:flutter/material.dart';
import 'daily_progress.dart'; // <-- 1. Impor halaman daily progress
import 'profile.dart';
import 'leaderboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      // Bottom Navigation Bar dengan Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.grey),
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
            const SizedBox(width: 48), // Spasi untuk FAB
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian AppBar Kustom
              _buildAppBar(),
              const SizedBox(height: 24),

              // Teks Sambutan
              const Text(
                'Hello',
                style: TextStyle(color: Colors.white70, fontSize: 22),
              ),
              const Text(
                'Nadila',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Tab
              _buildTabs(),
              const SizedBox(height: 30),

              // Kartu Daily Progress
              _buildDailyProgressCard(context), // <-- 2. Beri context
              const SizedBox(height: 30),

              // Judul Categories
              const Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Grid untuk Kategori
              _buildCategoryGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk AppBar
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://placehold.co/100x100/2C2C2E/FFFFFF?text=EB',
                ), // Ganti dengan URL gambar profil
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk Tombol Tab
  Widget _buildTabs() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Overview', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 15),
        TextButton(
          onPressed: () {},
          child: Text(
            'Productivity',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  // Widget untuk Kartu Daily Progress
  Widget _buildDailyProgressCard(BuildContext context) {
    // <-- 2. Terima context
    // 3. Bungkus dengan GestureDetector untuk navigasi
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DailyProgressPage()),
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
                // Placeholder untuk avatar tim
                SizedBox(
                  width: 60,
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue,
                      ),
                      Positioned(
                        left: 15,
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '76%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.76,
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

  // Widget untuk Grid Kategori
  Widget _buildCategoryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1 / 1.1,
      children: [
        _buildCategoryCard(
          icon: Icons.book_outlined,
          iconColor: Colors.blue,
          taskCount: 5,
          categoryName: 'Al-Quran',
          progress: 9 / 24,
          progressText: '9/24',
        ),
        _buildCategoryCard(
          icon: Icons.email_outlined,
          iconColor: Colors.orange,
          taskCount: 2,
          categoryName: 'Sedekah',
          progress: 4 / 15,
          progressText: '4/15',
        ),
        _buildCategoryCard(
          icon: Icons.check_circle_outline,
          iconColor: Colors.purple,
          taskCount: 9,
          categoryName: 'Work',
          progress: 3 / 15,
          progressText: '3/15',
        ),
        _buildCategoryCard(
          icon: Icons.notification_important_outlined,
          iconColor: Colors.green,
          taskCount: 5,
          categoryName: 'Reminder',
          progress: 9 / 24,
          progressText: '9/24',
        ),
      ],
    );
  }

  // Widget untuk satu kartu kategori
  Widget _buildCategoryCard({
    required IconData icon,
    required Color iconColor,
    required int taskCount,
    required String categoryName,
    required double progress,
    required String progressText,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor),
              ),
              // Placeholder untuk avatar tim
              SizedBox(
                width: 40,
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue,
                    ),
                    Positioned(
                      left: 10,
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$taskCount New',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            categoryName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade700,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              progressText,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
