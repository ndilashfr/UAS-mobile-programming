import 'package:flutter/material.dart';
import 'my_challenge_list.dart';
import 'profile.dart';
import 'leaderboard.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. BUTUH INI
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- 1. BUTUH INI
import 'category_detail_page.dart'; // Impor halaman detail kategori
import 'notification.dart'; // (Pastikan impor ini ada)
import 'create_challenge.dart'; // (Pastikan impor ini ada)
import 'overview_page.dart';
import 'productivity_page.dart';
import 'book_page.dart';



// --- 2. UBAH JADI STATEFULWIDGET ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- 3. TAMBAHKAN STATE UNTUK USER STREAM ---
  User? _user;
  Stream<DocumentSnapshot>? _userStream;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .snapshots();
    }
  }
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      // Bottom Navigation Bar (Pastikan sudah ada)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
              icon: const Icon(Icons.home, color: Colors.white), // Aktif
              onPressed: () {},
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
      // --- Body Utama ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian AppBar Kustom
              _buildAppBar(context),
              const SizedBox(height: 24),

              // --- 4. GANTI BLOK TEKS SAMBUTAN ---
              _buildWelcomeText(), // Panggil widget dinamis baru
              // ---------------------------------
              
              const SizedBox(height: 20),

             
              // Kartu Daily Progress
              _buildDailyProgressCard(context),
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

              // Grid untuk Kategori (StreamBuilder)
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1 / 1.0,
                    ),
                    itemCount: categories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final categoryDoc = categories[index];
                      final data =
                          categoryDoc.data() as Map<String, dynamic>;

                      final categoryName = data['name'] ?? 'Tanpa Nama';
                      final iconString = data['icon'] ?? 'default';

                      return GestureDetector(
                        onTap: () {
                         if (categoryName.toLowerCase() == 'reading' || categoryName.toLowerCase() == 'buku') {
      // Arahkan ke Halaman API Buku (UAS REQUIREMENT)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookPage()), // <-- Pastikan import book_page.dart
      );
    } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(
                                categoryName: categoryName,
                              ),
        ),
      );
    }
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
        ),
      ),
    );
  }

  // --- 5. TAMBAHKAN FUNGSI BARU INI ---
  Widget _buildWelcomeText() {
    if (_userStream == null) {
      // Jika user tidak login (atau stream gagal)
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello,',
            style: TextStyle(color: Colors.white70, fontSize: 22),
          ),
          Text(
            'Guest', // Tampilkan default
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    // Gunakan StreamBuilder untuk teks sambutan
    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, snapshot) {
        String displayName = '...'; // Teks loading

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          displayName = userData['displayName'] ?? 'User';
        } else if (snapshot.hasError) {
          displayName = 'Error';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello,',
              style: TextStyle(color: Colors.white70, fontSize: 22),
            ),
            Text(
              displayName, // <-- DATA DINAMIS
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
  // ----------------------------------

Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Judul "Home"
          const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // --- AVATAR DINAMIS (VERSI LEBIH AMAN) ---
          StreamBuilder<DocumentSnapshot>(
            stream: _userStream, // Gunakan stream yang sudah ada
            builder: (context, snapshot) {
              
              String photoUrl = '';
              String placeholderText = '?';

              // Jika data ada dan berhasil diambil
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                photoUrl = data['photoUrl'] ?? ''; // Ambil URL foto
                final displayName = data['displayName'] ?? '?';
                placeholderText = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
              }
              // Jika loading, error, atau photoUrl kosong, 
              // 'photoUrl' akan kosong.

              // Tampilkan CircleAvatar-nya
              return Row(
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF555555), // Warna background
                    // Jika photoUrl TIDAK KOSONG, gunakan NetworkImage
                    backgroundImage: (photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl) 
                        : null, // Jika kosong, jangan pakai background image
                    
                    // Jika photoUrl KOSONG, tampilkan teks inisial
                    child: (photoUrl.isEmpty)
                        ? Text(
                            placeholderText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null, // Jika ada gambar, jangan tampilkan teks
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildTabs() {
  //   // ... (kode _buildTabs kamu tidak berubah)
  //   return Row(
  //     children: [
  //       ElevatedButton(
  //         onPressed: () {},
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: const Color(0xFF007AFF),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //         ),
  //         child: const Text('Overview', style: TextStyle(color: Colors.white)),
  //       ),
  //       const SizedBox(width: 15),
  //       TextButton(
  //         onPressed: () {},
  //         child: Text(
  //           'Productivity',
  //           style: TextStyle(color: Colors.grey.shade400),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDailyProgressCard(BuildContext context) {
    // 1. Cek jika user tidak login, tampilkan card statis
    if (_user == null) {
      // Tampilkan card default jika user logout
      return _buildProgressCardUI(
        context: context,
        progressValue: 0.0,
        percentText: '0%',
        avatars: [], // Kosong
      );
    }

    // 2. Jika user login, gunakan StreamBuilder
    return StreamBuilder<QuerySnapshot>(
      // Ambil SEMUA dokumen partisipan milik user ini
      stream: FirebaseFirestore.instance
          .collection('participants')
          .where('userId', isEqualTo: _user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // 3. Handle loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildProgressCardUI(
            context: context,
            progressValue: 0.0,
            percentText: '...%', // Teks loading
            avatars: [],
          );
        }

        // 4. Handle error atau tidak ada data
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Tampilkan 0% jika user belum join challenge apapun
          return _buildProgressCardUI(
            context: context,
            progressValue: 0.0,
            percentText: '0%',
            avatars: [],
          );
        }

        // 5. Kalkulasi Progress Total
        final participantDocs = snapshot.data!.docs;
        double totalUserProgress = 0;
        double totalPossibleProgress = 0;
        List<String> photoUrls = []; // Untuk avatar

        for (var doc in participantDocs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          totalUserProgress += (data['progress'] ?? 0);
          
          // Gunakan field 'challengeDuration' yg kita simpan
          // Jika tidak ada (data lama), anggap durasinya 1
          totalPossibleProgress += (data['challengeDuration'] ?? 1); 

          // Ambil 2 photoUrl pertama untuk avatar
          if (photoUrls.length < 2 && data['photoUrl'] != null) {
            photoUrls.add(data['photoUrl']);
          }
        }

        // 6. Hitung persentase
        double progressValue = 0.0;
        if (totalPossibleProgress > 0) {
          progressValue = totalUserProgress / totalPossibleProgress;
        }
        
        // Pastikan tidak lebih dari 100%
        progressValue = progressValue.clamp(0.0, 1.0); 

        String progressPercent = (progressValue * 100).toStringAsFixed(0);

        // 7. Kembalikan UI dengan data dinamis
        return _buildProgressCardUI(
          context: context,
          progressValue: progressValue,
          percentText: '$progressPercent%',
          avatars: photoUrls,
        );
      },
    );
  }

  // FUNGSI 2: UI (Ini adalah kode lama Anda, tapi dengan parameter)
  Widget _buildProgressCardUI({
    required BuildContext context,
    required double progressValue,
    required String percentText,
    required List<String> avatars,
  }) {
    // Membuat tumpukan avatar
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
                SizedBox(
                  width: 60,
                  // Tampilkan avatar dinamis
                  child: Stack(
                    children: avatarStack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // --- Teks Persen DINAMIS ---
            Text(
              percentText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // --- Progress Bar DINAMIS ---
            LinearProgressIndicator(
              value: progressValue, // <-- DINAMIS
              backgroundColor: Colors.grey.shade700,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
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
    // ... (kode _buildCategoryCard kamu tidak berubah)
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
    // ... (kode _getIconForCategory kamu tidak berubah)
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
    // ... (kode _getColorForCategory kamu tidak berubah)
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