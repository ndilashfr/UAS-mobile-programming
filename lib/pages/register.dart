import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Buat Akun di Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        String cleanName = _nameController.text.trim().toUpperCase().replaceAll(' ', '');
        // Ambil 4 digit UID biar unik, misal: ABE-F3A1
        String myUniqueCode = '$cleanName-${uid.substring(0, 4).toUpperCase()}';

        // Persiapkan data dasar
        Map<String, dynamic> userData = {
          'uid': uid,
          'displayName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': null,
          'totalPoints': 0, 
          'myCode': myUniqueCode, // Simpan kode dia sendiri ke DB
        };

        // 2. LOGIKA REFERRAL (Cari Pemilik Kode)
        if (_referralController.text.trim().isNotEmpty) {
          String inputCode = _referralController.text.trim().toUpperCase();
          
          // Cari di database: Siapa yang punya 'myCode' == inputCode?
          QuerySnapshot query = await FirebaseFirestore.instance
              .collection('users')
              .where('myCode', isEqualTo: inputCode)
              .get();

          if (query.docs.isNotEmpty) {
            // Ketemu! Ambil UID pemilik kode
            String referrerUid = query.docs.first.id;
            
            // Simpan UID pemilik sebagai 'referredBy'
            // Ini kunci agar muncul di list 'Lihat siapa yang bergabung' di Profile.dart
            userData['referredBy'] = referrerUid; 
            userData['referredByCode'] = inputCode; // Simpan kodenya juga buat histori
          } else {
            // Kalau kode tidak ditemukan, biarkan saja (atau bisa kasih error)
            print("Kode referral tidak ditemukan, lanjut daftar tanpa referral.");
          }
        }

        // 3. Simpan ke Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

        // 4. Update Display Name
        await userCredential.user!.updateDisplayName(_nameController.text.trim());

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Join the challenge community!',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
              const SizedBox(height: 30),

              _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline),
              const SizedBox(height: 16),
              
              _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, inputType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              
              _buildTextField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 16),

              // Kolom Referral
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: _buildTextField(
                  controller: _referralController,
                  label: 'Kode Undangan (Opsional)',
                  icon: Icons.card_giftcard,
                  isReferral: true
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text("Punya kode dari teman? Masukkan di sini.", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ),
              const SizedBox(height: 32),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isReferral = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword,
      keyboardType: inputType,
      textCapitalization: isReferral ? TextCapitalization.characters : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: isReferral ? Colors.blueAccent : Colors.grey.shade400, size: 20),
        
        // Tombol Paste
        suffixIcon: isReferral
            ? IconButton(
                icon: const Icon(Icons.content_paste_rounded, color: Colors.blueAccent),
                tooltip: "Tempel Kode",
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data != null && data.text != null) {
                    controller.text = data.text!;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kode ditempel!"), duration: Duration(milliseconds: 800)),
                    );
                  }
                },
              )
            : null,
            
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5)),
      ),
    );
  }
}