import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Pastikan sudah install package ini

import 'challenge_detail_page.dart'; // Import detail page
import 'create_challenge.dart';

class MyChallengeListPage extends StatefulWidget {
  const MyChallengeListPage({super.key});

  @override
  State<MyChallengeListPage> createState() => _MyChallengeListPageState();
}

class _MyChallengeListPageState extends State<MyChallengeListPage> {
  User? _user;
  String _currentFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar tidak memakan memori
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNGSI KELUAR CHALLENGE (Dipindahkan kesini) ---
  Future<void> _leaveChallenge(String challengeId) async {
    if (_user == null) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          'Keluar Challenge',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Yakin ingin keluar? Progresmu akan hilang.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final participantDocId = '${_user!.uid}_$challengeId';

        // Hapus data partisipan
        batch.delete(
          FirebaseFirestore.instance
              .collection('participants')
              .doc(participantDocId),
        );

        // Update data challenge (kurangi member)
        batch.update(
          FirebaseFirestore.instance.collection('challenges').doc(challengeId),
          {
            'members': FieldValue.increment(-1),
            'participantUIDs': FieldValue.arrayRemove([_user!.uid]),
          },
        );

        await batch.commit();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil keluar challenge.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daily Progress',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search Bar Dummy
            TextField(
              controller: _searchController, // Pasang controller
              onChanged: (value) {
                setState(() {}); // Rebuild UI setiap kali user mengetik
              },
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Filter Buttons
            Row(
              children: [
                _buildFilterButton('All'),
                const SizedBox(width: 12),
                _buildFilterButton('Favorite'),
              ],
            ),
            const SizedBox(height: 20),

            // --- LIST CHALLENGE YANG DIIKUTI ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Query challenge yang diikuti user
                stream: FirebaseFirestore.instance
                    .collection('challenges')
                    .where('participantUIDs', arrayContains: _user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Kamu belum bergabung challenge apapun.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  var challenges = snapshot.data!.docs;

                  // Filter A: Berdasarkan Search Text
                  if (_searchController.text.isNotEmpty) {
                    challenges = challenges.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title = (data['title'] ?? '')
                          .toString()
                          .toLowerCase();
                      final query = _searchController.text.toLowerCase();
                      return title.contains(
                        query,
                      ); // Cek apakah judul mengandung text search
                    }).toList();
                  }

                  // Filter B: Berdasarkan Tombol Favorite
                  if (_currentFilter == 'Favorite') {
                    challenges = challenges.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final favs = List<String>.from(data['favoritedBy'] ?? []);
                      return favs.contains(_user?.uid);
                    }).toList();
                  }

                  // Cek jika hasil filter kosong
                  if (challenges.isEmpty) {
                    return const Center(
                      child: Text(
                        "Tidak ada challenge ditemukan.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: challenges
                        .length, // Gunakan length dari list yang sudah difilter
                    itemBuilder: (context, index) {
                      final doc = challenges[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Slidable(
                          key: ValueKey(doc.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) => _leaveChallenge(doc.id),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.exit_to_app,
                                label: 'Keluar',
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // Buka Detail Page saat diklik
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChallengeDetailPage(challengeId: doc.id),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C2E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Ikon Kategori
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.blue.withOpacity(
                                      0.2,
                                    ),
                                    child: const Icon(
                                      Icons.task_alt,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'] ?? 'Tanpa Judul',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Kategori: ${data['category']}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Navigasi Bawah (FAB)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateChallengePage()),
        ),
        backgroundColor: const Color(0xFF007AFF),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // ... (BottomNavBar sama seperti file lain)
    );
  }

  Widget _buildFilterButton(String text) {
    bool isActive = _currentFilter == text;
    return ElevatedButton(
      onPressed: () => setState(() => _currentFilter = text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? const Color(0xFF007AFF)
            : const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(color: isActive ? Colors.white : Colors.grey),
      ),
    );
  }
}
