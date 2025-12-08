import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  // Fungsi untuk mengirim notifikasi ke Database User Lain
  static Future<void> sendNotification({
    required String toUserId,      // ID Penerima (Nadila)
    required String senderName,    // Nama Pengirim (Natsuki)
    required String message,       // Isi pesan (misal: Challenge Title)
    required String type,          // 'join' atau 'like'
  }) async {
    
    String title = '';
    String subtitle = '';
    String iconName = 'notifications';
    String colorName = 'grey';

    // Tentukan isi pesan berdasarkan tipe aksi
    if (type == 'join') {
      title = '$senderName bergabung!';
      subtitle = '$senderName baru saja join ke tantangan: "$message"';
      iconName = 'person_add'; // Ikon orang
      colorName = 'blue';
    } else if (type == 'like') {
      title = '$senderName menyukai tantanganmu';
      subtitle = 'Terus semangat! Tantangan "$message" keren.';
      iconName = 'emoji_events'; // Ikon piala
      colorName = 'yellow';
    }
// --- TAMBAHAN BARU: TIPE RANK ---
    else if (type == 'rank') {
      title = 'Update Peringkat! 🏆';
      subtitle = message; // Pesan dinamis: "Kamu sekarang peringkat #3"
      iconName = 'trending_up'; // Ikon grafik naik
      colorName = 'green';
    }
    try {
      // KIRIM KE DATABASE NOTIFICATIONS
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': toUserId, // PENTING: Ini ID si Pemilik Challenge (Nadila)
        'title': title,
        'subtitle': subtitle,
        'iconName': iconName,
        'colorName': colorName,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      print("Notifikasi berhasil dikirim ke $toUserId");
    } catch (e) {
      print("Gagal kirim notif: $e");
    }
  }
}