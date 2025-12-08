import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart'; // <-- PENTING: Import service ini

class ChallengeDetailPage extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailPage({super.key, required this.challengeId});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  bool _isLoading = false;
  User? _user; // <-- 1. Tambahkan state user

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser; // <-- 2. Ambil user saat ini
  }

  Future<void> _checkRankAndNotify() async {
    if (_user == null) return;

    try {
      // 1. Ambil semua peserta DI CHALLENGE INI SAJA
      //    Urutkan berdasarkan score tertinggi
      final snapshot = await FirebaseFirestore.instance
          .collection('participants')
          .where(
            'challengeId',
            isEqualTo: widget.challengeId,
          ) // Filter Challenge ID
          .orderBy('score', descending: true) // Urutkan Score tertinggi
          .get();

      final allParticipants = snapshot.docs;
      int myRank = -1;

      // 2. Cari urutan kita (Looping manual untuk cari index)
      for (int i = 0; i < allParticipants.length; i++) {
        final data = allParticipants[i].data();
        // Cek apakah ini data kita?
        if (data['userId'] == _user!.uid) {
          myRank = i + 1; // Index mulai dari 0, jadi rank = index + 1
          break;
        }
      }

      // 3. Kirim Notifikasi Peringkat ke Diri Sendiri
      if (myRank > 0) {
        String message =
            "Progres mantap! Kamu sekarang ada di Peringkat #$myRank untuk challenge ini.";

        // Pesan spesial kalau masuk Top 3
        if (myRank == 1) {
          message =
              "RAJA CHALLENGE! 👑 Kamu sekarang memimpin di Peringkat #1!";
        } else if (myRank <= 3) {
          message = "LUAR BIASA! 🔥 Kamu masuk Top 3 (Peringkat #$myRank)!";
        }

        // Kirim notif ke diri sendiri
        await NotificationService.sendNotification(
          toUserId: _user!.uid,
          senderName: "Sistem",
          message: message,
          type: 'rank',
        );

        print("Notifikasi peringkat dikirim: Rank $myRank");
      }
    } catch (e) {
      print("Gagal cek peringkat: $e");
    }
  }

  Future<void> _joinChallenge() async {
    setState(() {
      _isLoading = true;
    });

    if (_user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Ambil data user (Natsuki) untuk info pengirim
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;
      String myName = userData['displayName'] ?? 'Seseorang';

      // 2. Ambil data Challenge
      final challengeDocRef = FirebaseFirestore.instance
          .collection('challenges')
          .doc(widget.challengeId);
      final challengeSnapshot = await challengeDocRef.get();

      if (!challengeSnapshot.exists)
        throw Exception("Challenge tidak ditemukan!");
      final challengeData = challengeSnapshot.data() as Map<String, dynamic>;

      // --- LOGIKA PENCARIAN PEMILIK ---
      String ownerId = '';

      // Cek 1: Apakah ada field 'ownerId'? (Data Baru)
      if (challengeData.containsKey('ownerId')) {
        ownerId = challengeData['ownerId'];
      }
      // Cek 2: Jika tidak ada, apakah ada 'creator' (email)? (Data Lama)
      else if (challengeData.containsKey('creator')) {
        String creatorEmail = challengeData['creator'];
        // Cari User ID berdasarkan email (Query tambahan)
        var userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: creatorEmail)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          ownerId = userQuery.docs.first.id;
        }
      }

      // Jika ownerId masih kosong, kita tidak bisa kirim notif
      if (ownerId.isEmpty) {
        print("Peringatan: Tidak dapat menemukan ID pemilik challenge ini.");
      }

      // Cek: Jangan join tantangan sendiri
      if (ownerId == _user!.uid) {
        throw Exception("Kamu tidak bisa join tantangan buatan sendiri!");
      }
      // -------------------------------

      // 3. Proses Join (Simpan ke Participants)
      final participantDocId = '${_user!.uid}_${widget.challengeId}';
      final participantDocRef = FirebaseFirestore.instance
          .collection('participants')
          .doc(participantDocId);
      final batch = FirebaseFirestore.instance.batch();

      batch.set(participantDocRef, {
        'score': 0,
        'progress': 0,
        'userId': _user!.uid,
        'challengeId': widget.challengeId,
        'displayName': myName,
        'photoUrl': userData['photoUrl'] ?? '',
        'joinedAt': FieldValue.serverTimestamp(),
        'challengeDuration': challengeData['duration'] ?? 1,
      });

      batch.update(challengeDocRef, {
        'members': FieldValue.increment(1),
        'participantUIDs': FieldValue.arrayUnion([_user!.uid]),
      });

      await batch.commit();

      // 4. KIRIM NOTIFIKASI (Hanya jika ownerId ditemukan)
      if (ownerId.isNotEmpty) {
        await NotificationService.sendNotification(
          toUserId: ownerId,
          senderName: myName,
          message: challengeData['title'] ?? 'Tantangan',
          type: 'join',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil bergabung!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  Future<void> _updateProgress() async {
    setState(() {
      _isLoading = true;
    });
    if (_user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final challengeDocRef = FirebaseFirestore.instance
          .collection('challenges')
          .doc(widget.challengeId);
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid);
      final participantDocId = '${_user!.uid}_${widget.challengeId}';
      final participantDocRef = FirebaseFirestore.instance
          .collection('participants')
          .doc(participantDocId);

      // 1. Ambil data Challenge & Partisipan
      final challengeDoc = await challengeDocRef.get();
      if (!challengeDoc.exists)
        throw Exception("Dokumen challenge tidak ditemukan!");
      final int duration =
          (challengeDoc.data() as Map<String, dynamic>)['duration'] ?? 1;

      final participantDoc = await participantDocRef.get();
      if (!participantDoc.exists)
        throw Exception("Kamu belum bergabung challenge ini!");

      final participantData = participantDoc.data() as Map<String, dynamic>;
      final int currentProgress = participantData['progress'] ?? 0;
      final int newProgress =
          currentProgress + 1; // Hitung target progres hari ini
      const int pointsToAdd = 10;

      // Ambil data user untuk update display name (jika perlu)
      final userDoc = await userDocRef.get();
      final userData = userDoc.data() as Map<String, dynamic>;

      final batch = FirebaseFirestore.instance.batch();

      // --- LOGIKA UTAMA: CEK APAKAH INI HARI TERAKHIR ---
      if (newProgress >= duration) {
        // === SKENARIO CHALLENGE SELESAI (RESET OTOMATIS) ===

        // 1. Berikan Poin Terakhir ke Global User Score
        batch.update(userDocRef, {
          'totalPoints': FieldValue.increment(pointsToAdd),
        });

        // 2. HAPUS Data Partisipan (Agar tombol berubah jadi 'Join' lagi)
        batch.delete(participantDocRef);

        // 3. Update Challenge (Kurangi jumlah member & hapus UID dari array)
        batch.update(challengeDocRef, {
          'members': FieldValue.increment(-1),
          'participantUIDs': FieldValue.arrayRemove([_user!.uid]),
        });

        await batch.commit();

        if (mounted) {
          // Tampilkan Notifikasi Selesai & Reset
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'SELAMAT! Challenge Selesai 🎉 (+10 Poin). Kamu telah keluar otomatis dan bisa join lagi dari awal.',
              ),
              backgroundColor: Colors.purple, // Warna beda biar spesial
              duration: Duration(seconds: 4),
            ),
          );
        }
        // Catatan: Kita TIDAK panggil _checkRankAndNotify() disini karena data partisipan sudah dihapus.
      } else {
        // === SKENARIO PROGRES HARIAN BIASA (KODE ASLI KAMU) ===

        // 1. Update Global Poin User
        batch.update(userDocRef, {
          'totalPoints': FieldValue.increment(pointsToAdd),
        });

        // 2. Update Data Partisipan (Tambah Score & Progress)
        batch.set(participantDocRef, {
          'score': FieldValue.increment(pointsToAdd),
          'progress': FieldValue.increment(1),
          'userId': _user!.uid,
          'challengeId': widget.challengeId,
          'displayName': userData['displayName'] ?? 'User',
          'photoUrl': userData['photoUrl'] ?? '',
        }, SetOptions(merge: true));

        await batch.commit();

        // Cek Rank hanya saat progres biasa
        _checkRankAndNotify();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hore! Progres +1 dan kamu dapat +10 poin!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update progres: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(bool isCurrentlyFavorited) async {
    if (_user == null) return; // Pastikan user login

    final challengeDocRef = FirebaseFirestore.instance
        .collection('challenges')
        .doc(widget.challengeId);

    try {
      if (isCurrentlyFavorited) {
        // Jika sudah favorit, hapus dari list
        await challengeDocRef.update({
          'favoritedBy': FieldValue.arrayRemove([_user!.uid]),
        });
      } else {
        // Jika belum favorit, tambahkan ke list
        await challengeDocRef.update({
          'favoritedBy': FieldValue.arrayUnion([_user!.uid]),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update favorit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Tidak perlu setState, StreamBuilder akan meng-handle update UI
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder dipindahkan ke luar membungkus Scaffold
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .doc(widget.challengeId)
          .snapshots(),
      builder: (context, snapshot) {
        // Logika loading dan error (SAMA SEPERTI KODE LAMA ANDA)
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: const Center(child: Text('Gagal mengambil data.')),
          );
        }
        if (!snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: const Center(child: Text('Challenge tidak ditemukan.')),
          );
        }

        // Ekstraksi data (SAMA SEPERTI KODE LAMA ANDA)
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final title = data['title'] ?? 'Tanpa Judul';
        final description = data['description'] ?? 'Tidak ada deskripsi.';
        final duration = data['duration'] ?? 0;
        final members = data['members'] ?? 1;
        final String creatorEmail = data['creator'] ?? 'Tidak diketahui';

        // --- TAMBAHAN: Logika untuk status favorit ---
        // (Asumsi Anda punya field array 'favoritedBy' di 'challenges')
        final favoritedByList = List<String>.from(data['favoritedBy'] ?? []);
        final bool isFavorited = favoritedByList.contains(_user?.uid);
        // --- AKHIR TAMBAHAN ---

        // Sekarang kita return Scaffold-nya
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Challenge Detail',
              style: TextStyle(color: Colors.white),
            ),
            // --- TAMBAHAN: Tombol Aksi untuk Favorit ---
            actions: [
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.redAccent : Colors.white,
                ),
                onPressed: () {
                  // Panggil fungsi toggle
                  _toggleFavorite(isFavorited);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                // --- Info Challenge ---
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dibuat oleh: $creatorEmail',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Hanya satu SizedBox
                // --- Info Statistik ---
                const Divider(color: Color(0xFF2C2C2E)),
                const SizedBox(height: 16),

                _buildInfoRow(
                  // Baris 1: Durasi
                  icon: Icons.calendar_today_outlined,
                  title: 'Durasi Challenge',
                  value: '$duration hari',
                ),

                // Baris 2: Progres PRIBADI (Dinamis)
                _buildUserProgressRow(duration: duration),

                // Baris 3: List Avatar Anggota (Dinamis)
                _buildParticipantList(totalMembers: members),

                // (Baris 'Progres Saat Ini' dan 'Total Anggota' yang statis sudah DIHAPUS)
                const SizedBox(height: 30),

                // --- Tombol Aksi ---
                _buildDynamicButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicButton() {
    if (_user == null) return const SizedBox();
    final String participantDocId = '${_user!.uid}_${widget.challengeId}';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('participants')
          .doc(participantDocId)
          .snapshots(),
      builder: (context, snapshot) {
        final bool hasJoined = snapshot.hasData && snapshot.data!.exists;
        if (hasJoined) {
          return ElevatedButton(
            onPressed: _isLoading ? null : _updateProgress,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    'Tandai Selesai Hari Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          );
        }
        return ElevatedButton(
          onPressed: _isLoading ? null : _joinChallenge,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Text(
                  'Join Challenge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProgressRow({required int duration}) {
    if (_user == null) return const SizedBox();
    final String participantDocId = '${_user!.uid}_${widget.challengeId}';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('participants')
          .doc(participantDocId)
          .snapshots(),
      builder: (context, snapshot) {
        int userProgress = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userProgress = data['progress'] ?? 0;
        }
        return _buildInfoRow(
          icon: Icons.check_circle_outline,
          title: 'Progres Kamu',
          value: '$userProgress / $duration hari',
        );
      },
    );
  }

  Widget _buildParticipantList({required int totalMembers}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('participants')
          .where('challengeId', isEqualTo: widget.challengeId)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildInfoRow(
            icon: Icons.people_outline,
            title: 'Total Anggota',
            value: '$totalMembers orang',
          );
        }
        final participants = snapshot.data!.docs;
        List<Widget> avatarWidgets = [];
        for (int i = 0; i < participants.length; i++) {
          final data = participants[i].data() as Map<String, dynamic>;
          final photoUrl = data['photoUrl'] ?? 'https://placehold.co/100';
          avatarWidgets.add(
            Positioned(
              left: (i * 25.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF1A1A1A),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(photoUrl),
                  backgroundColor: Colors.grey.shade800,
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.people_outline, color: Colors.grey.shade500, size: 20),
              const SizedBox(width: 16),
              Text(
                'Anggota',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
              const Spacer(),
              SizedBox(
                width: (participants.length * 25.0) + 10.0,
                height: 36,
                child: Stack(children: avatarWidgets),
              ),
              if (totalMembers > 5)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '+${totalMembers - 5}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
