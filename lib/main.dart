import 'package:flutter/material.dart';
import 'pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Challenge App',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter', // Pastikan font Inter sudah ada di pubspec.yaml
      ),
      debugShowCheckedModeBanner: false, // Menghilangkan banner "DEBUG"

      // 2. Alur aplikasi dimulai dari sini
      // Aplikasi akan membuka LoginPages() terlebih dahulu.
      home: const LoginPages(),

      // 3. (Opsional) Anda bisa definisikan rute di sini
      //    agar navigasi lebih rapi, tapi untuk sekarang 'home' sudah cukup.
    );
  }
}

