import 'package:community_challenge_app/pages/home.dart';
import 'package:flutter/material.dart';
import 'register.dart';

// 1. Impor Firebase Auth
import 'package:firebase_auth/firebase_auth.dart';

// 2. Ubah menjadi StatefulWidget
class LoginPages extends StatefulWidget {
  const LoginPages({super.key});

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  // 3. Buat controller untuk text field
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  // TAMBAHKAN state untuk notifikasi sukses
  String? _successMessage;

  // 4. Buat fungsi untuk Sign In
  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 5. Panggil fungsi sign-in Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 6. Jika berhasil, pindah ke HomePage
      // (Kita gunakan 'mounted' untuk memastikan widget masih ada)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 7. Tangani error jika login gagal

      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = "Email dan password tidak boleh kosong.";
        });
        return;
      }

      setState(() {
        _errorMessage = e.message ?? "Terjadi kesalahan";
        _successMessage = null; // Hapus pesan sukses jika ada
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- TAMBAHKAN FUNGSI BARU UNTUK LUPA PASSWORD ---
  Future<void> _resetPassword() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Masukkan email Anda untuk mereset password.";
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Kirim email reset
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      // Tampilkan pesan sukses
      setState(() {
        _successMessage = "Link reset password telah dikirim ke email Anda.";
      });
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link reset password telah dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _errorMessage = e.message ?? "Gagal mengirim email reset.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // --- AKHIR FUNGSI BARU ---

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/Image.png',
                height: 200,
              ), // Kecilkan gambar
              const SizedBox(height: 30),
              const Text(
                'The only\nproductivity\napp you need',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40, // Kecilkan font
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              // 8. TAMBAHKAN KOLOM INPUT EMAIL
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Email',
                  Icons.email_outlined,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // 9. TAMBAHKAN KOLOM INPUT PASSWORD
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  'Password',
                  Icons.lock_outline,
                ),
                obscureText: true, // Sembunyikan password
              ),
              const SizedBox(height: 20),

              // 10. Tampilkan pesan error jika ada
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // --- TAMBAHKAN PESAN SUKSES ---
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              // --- AKHIR PESAN SUKSES ---

              // 11. Tombol Sign In
              ElevatedButton(
                // 12. Panggil fungsi _signInWithEmail
                onPressed: _isLoading ? null : _signInWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sign in with Email',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // --- TAMBAHKAN TOMBOL LUPA PASSWORD ---
              TextButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: const Text(
                  'Lupa Password?',
                  style: TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Belum punya akun? ",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigasi ke halaman Register
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Daftar di sini",
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Spacer bawah agar elemen terdorong ke tengah-atas sedikit
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk styling text field
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      filled: true,
      fillColor: const Color(0xFF2C2C2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
      ),
    );
  }
}
