import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book_model.dart';

class BookService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Fungsi untuk mencari buku berdasarkan query
  Future<List<Book>> searchBooks(String query) async {
    // Jika query kosong, default cari buku tentang 'productivity'
    final searchTerm = query.isEmpty ? 'productivity' : query;
    
    final url = Uri.parse('$_baseUrl?q=$searchTerm&maxResults=20');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Cek jika ada items
        if (data['items'] != null) {
          final List<dynamic> items = data['items'];
          // Konversi List JSON ke List<Book>
          return items.map((json) => Book.fromJson(json)).toList();
        } else {
          return []; // Tidak ada hasil
        }
      } else {
        throw Exception('Gagal memuat buku: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
}