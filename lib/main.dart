import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login.dart';
import 'firebase_options.dart'; // Jika kamu sudah pakai konfigurasi Firebase CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // otomatis sesuai platform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Challenge App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      home: const FirebaseInit(),
    );
  }
}

// 🔹 Cegah error ketika Firebase belum selesai inisialisasi
class FirebaseInit extends StatelessWidget {
  const FirebaseInit({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1E1E1E),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF007AFF)),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Failed to connect Firebase')),
          );
        }
        return const LoginPages();
      },
    );
  }
}
