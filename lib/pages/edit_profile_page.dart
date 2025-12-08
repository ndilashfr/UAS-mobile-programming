import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  // 1. Halaman ini butuh data user yang mau diedit
  final DocumentSnapshot userDoc;

  const EditProfilePage({super.key, required this.userDoc});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // 2. Siapkan controller untuk form
  late TextEditingController _nameController;
  late TextEditingController _photoUrlController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 3. Ambil data lama dan masukkan ke controller
    final data = widget.userDoc.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['displayName'] ?? '');
    _photoUrlController = TextEditingController(text: data['photoUrl'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  // --- 4. Fungsi untuk menyimpan perubahan ---
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jangan lakukan apa-apa jika form tidak valid
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User tidak login");

      // Siapkan data baru
      final newData = {
        'displayName': _nameController.text,
        'photoUrl': _photoUrlController.text,
      };

      // Update dokumen di 'users'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(newData);

      // --- 5. (PENTING) Update juga 'participants' ---
      // Jika tidak, leaderboard akan menampilkan data lama
      // Kita query semua 'participants' milik user ini
      final querySnapshot = await FirebaseFirestore.instance
          .collection('participants')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Buat batch untuk update semua data participants
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'displayName': _nameController.text,
          'photoUrl': _photoUrlController.text,
        });
      }
      await batch.commit(); // Jalankan semua update participants

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman profil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update profil: $e'),
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
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // --- Tampilan Foto Saat Ini (dari URL) ---
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_photoUrlController.text.isNotEmpty
                    ? _photoUrlController.text
                    : 'https://placehold.co/100'),
                backgroundColor: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 30),

            // --- Form Nama ---
            Text(
              'Nama Tampilan',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(hint: 'Masukkan nama...'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // --- Form URL Foto ---
            Text(
              'URL Foto Profil',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _photoUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(hint: 'https://...'),
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    !value.startsWith('http')) {
                  return 'Harus berupa URL yang valid (diawali http)';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),

            // --- Tombol Update ---
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Update Profil',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk styling TextField
  InputDecoration _buildInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: const Color(0xFF2C2C2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    );
  }
}