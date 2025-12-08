import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home.dart';
import 'profile.dart';
import 'notification.dart';
import 'create_challenge.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _challengeOptions = [];
  Map<String, dynamic>? _selectedChallenge;
  bool _isLoadingChallenges = true;

  IconData _getIconForCategory(String category) {
    if (category.contains('Al-Quran')) return Icons.menu_book;
    if (category.contains('Productivity')) return Icons.check_circle_outline;
    if (category.contains('Reading')) return Icons.bookmark_border_rounded;
    if (category.toLowerCase() == 'ibadah') return Icons.mosque_outlined;
    if (category.toLowerCase() == 'kesehatan') return Icons.directions_run_outlined;
    if (category.toLowerCase() == 'produktifitas') return Icons.lightbulb_outline;
    return Icons.task_alt;
  }

  Future<void> _fetchChallenges() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('challenges').get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoadingChallenges = false;
        });
        return;
      }

      final challenges = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'text': data['title'] ?? 'Tanpa Judul',
          'icon': _getIconForCategory(data['category'] ?? ''),
        };
      }).toList();

      setState(() {
        _challengeOptions = challenges;
        if (_challengeOptions.isNotEmpty) {
          _selectedChallenge = _challengeOptions[0];
        }
        _isLoadingChallenges = false;
      });
    } catch (e) {
      print("Error fetching challenges: $e");
      setState(() {
        _isLoadingChallenges = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  @override
  Widget build(BuildContext context) {
    // ... (Fungsi build dan BottomNav tidak berubah)
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
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
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              onPressed: () {},
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      const SizedBox(height: 24),
                      _buildChallengeDropdown(), // <-- Panggil fungsi yang kita modif
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ];
          },
          // ... (StreamBuilder dan body sisanya tidak berubah)
          body: _isLoadingChallenges
              ? const Center(child: CircularProgressIndicator())
              : _selectedChallenge == null
                  ? const Center(
                      child: Text(
                      'Belum ada challenge.',
                      style: TextStyle(color: Colors.grey),
                    ))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('participants')
                          .where('challengeId',
                              isEqualTo: _selectedChallenge!['id'])
                          .orderBy('score', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error',
                                  style: TextStyle(color: Colors.white)));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('Belum ada peserta di challenge ini.',
                                  style: TextStyle(color: Colors.grey)));
                        }

                        final participants = snapshot.data!.docs;
                        final List<DocumentSnapshot> podiumUsers =
                            participants.length >= 3
                                ? participants.sublist(0, 3)
                                : participants;
                        final List<DocumentSnapshot> listUsers =
                            participants.length > 3
                                ? participants.sublist(3)
                                : [];

                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          children: [
                            _buildDynamicPodium(podiumUsers),
                            const SizedBox(height: 30),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Peringkat Lainnya',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...listUsers.map((userDoc) {
                              final data =
                                  userDoc.data() as Map<String, dynamic>;
                              final int rank = participants.indexWhere(
                                      (doc) => doc.id == userDoc.id) +
                                  1;

                              return _buildRankItem(
                                rank: rank,
                                name: data['displayName'] ?? 'User',
                                details: '${data['score'] ?? 0} Poin',
                                points: '${data['score'] ?? 0}',
                                picUrl: data['photoUrl'] ??
                                    'https://placehold.co/100',
                                isUser: data['userId'] == currentUserUid,
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    // ... (Tidak berubah)
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
        ],
      ),
    );
  }

  // --- 1. MODIFIKASI FUNGSI DROPDOWN INI ---
  Widget _buildChallengeDropdown() {
    if (_isLoadingChallenges) {
      return Container(
        // ... (Tampilan loading tetap sama)
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text("Memuat challenges...",
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    // GANTI JADI TOMBOL PALSU
    return GestureDetector(
      onTap: () {
        // Panggil fungsi untuk memunculkan modal
        _showChallengePicker(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tampilkan challenge yang dipilih
            _selectedChallenge == null
                ? Text( // Teks default
                    'Pilih Challenge',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Row( // Tampilkan ikon dan nama
                    children: [
                      Icon(
                        _selectedChallenge!['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedChallenge!['text'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
            // Ikon panah
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // --- 2. TAMBAHKAN FUNGSI BARU INI (UNTUK MODAL) ---
  void _showChallengePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E), // Warna background modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.5, // Setengah layar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Modal
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Pilih Challenge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Color(0xFF2C2C2E)),
              // List Pilihan
              Expanded(
                child: ListView.builder(
                  itemCount: _challengeOptions.length,
                  itemBuilder: (context, index) {
                    final option = _challengeOptions[index];
                    final isSelected =
                        _selectedChallenge?['id'] == option['id'];

                    return ListTile(
                      leading: Icon(
                        option['icon'] as IconData,
                        color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                      ),
                      title: Text(
                        option['text'] as String,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        // Set state & tutup modal
                        setState(() {
                          _selectedChallenge = option;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Sisa Widget (Podium & List) Tidak Berubah ---
  Widget _buildDynamicPodium(List<DocumentSnapshot> podiumUsers) {
    // ... (Kode _buildDynamicPodium tidak berubah)
    DocumentSnapshot? rank1User;
    DocumentSnapshot? rank2User;
    DocumentSnapshot? rank3User;

    if (podiumUsers.isNotEmpty) {
      rank1User = podiumUsers[0];
    }
    if (podiumUsers.length > 1) {
      rank2User = podiumUsers[1];
    }
    if (podiumUsers.length > 2) {
      rank3User = podiumUsers[2];
    }

    Map<String, dynamic> getData(DocumentSnapshot? doc) {
      if (doc != null && doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    }

    final dataRank1 = getData(rank1User);
    final dataRank2 = getData(rank2User);
    final dataRank3 = getData(rank3User);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: rank2User != null
              ? _buildPodiumMember(
                  rank: 2,
                  name: dataRank2['displayName'] ?? 'User',
                  points: '${dataRank2['score'] ?? 0} pts',
                  picUrl: dataRank2['photoUrl'] ?? 'https://placehold.co/100',
                  borderColor: Colors.grey.shade400,
                )
              : Container(),
        ),
        Expanded(
          child: rank1User != null
              ? _buildPodiumMember(
                  rank: 1,
                  name: dataRank1['displayName'] ?? 'User',
                  points: '${dataRank1['score'] ?? 0} pts',
                  picUrl: dataRank1['photoUrl'] ?? 'https://placehold.co/100',
                  borderColor: Colors.yellow.shade600,
                  isWinner: true,
                )
              : Container(),
        ),
        Expanded(
          child: rank3User != null
              ? _buildPodiumMember(
                  rank: 3,
                  name: dataRank3['displayName'] ?? 'User',
                  points: '${dataRank3['score'] ?? 0} pts',
                  picUrl: dataRank3['photoUrl'] ?? 'https://placehold.co/100',
                  borderColor: Colors.brown.shade400,
                )
              : Container(),
        ),
      ],
    );
  }

  Widget _buildPodiumMember({
    required int rank,
    required String name,
    required String points,
    required String picUrl,
    required Color borderColor,
    bool isWinner = false,
  }) {
    // ... (Kode _buildPodiumMember tidak berubah)
    double avatarRadius = isWinner ? 50 : 40;
    double verticalPadding = isWinner ? 0 : 20;

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
               child: CachedNetworkImage(
                  imageUrl: picUrl,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: avatarRadius, // Gunakan variabel avatarRadius
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: const Color(0xFF2C2C2E),
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: const Color(0xFF2C2C2E),
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
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
              textAlign: TextAlign.center,
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
    required String picUrl,
    bool isUser = false,
    bool? isUp,
  }) {
    // ... (Kode _buildRankItem tidak berubah)
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
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(picUrl),
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
        ],
      ),
    );
  }
}