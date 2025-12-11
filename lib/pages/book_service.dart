import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
      // tambahkan timeout agar panggilan tidak menggantung
      final response = await http.get(url).timeout(const Duration(seconds: 8));

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
        throw ApiException('Gagal memuat buku (kode: ${response.statusCode})');
      }
    } on TimeoutException catch (_) {
      throw NetworkException('Permintaan melebihi batas waktu. Periksa koneksi internet Anda.');
    } on SocketException catch (_) {
      throw NetworkException('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      throw ApiException('Terjadi kesalahan saat memuat buku: $e');
    }
  }

}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
