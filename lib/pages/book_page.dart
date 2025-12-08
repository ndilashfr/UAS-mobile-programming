import 'package:flutter/material.dart';
import 'book_model.dart';
import 'book_service.dart';
import 'book_detail_page.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final BookService _bookService = BookService();
  final TextEditingController _searchController = TextEditingController();
  
  // Variabel State (Syarat II.b.3: Loading, Success, Error State)
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBooks('productivity'); // Load awal (default)
  }

  // Fungsi untuk memanggil Service
  Future<void> _fetchBooks(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _bookService.searchBooks(query);
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rekomendasi Buku', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- SEARCH BAR (Syarat II.b.5: Fitur Pencarian) ---
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari buku (contoh: Atomic Habits)',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Color(0xFF007AFF)),
                  onPressed: () {
                    // Panggil API saat tombol ditekan
                    _fetchBooks(_searchController.text);
                    FocusScope.of(context).unfocus(); // Tutup keyboard
                  },
                ),
              ),
              onSubmitted: (value) => _fetchBooks(value),
            ),
            const SizedBox(height: 20),

            // --- HASIL PENCARIAN (List View) ---
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text('Terjadi Kesalahan:\n$_errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchBooks(_searchController.text),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    // 3. Empty State
    if (_books.isEmpty) {
      return const Center(child: Text("Buku tidak ditemukan.", style: TextStyle(color: Colors.grey)));
    }

    // 4. Success State (Tampilkan List)
    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return GestureDetector( // <--- Tambahkan Widget ini
  onTap: () {
    // Navigasi ke halaman detail saat buku diklik
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailPage(book: book), // <-- Panggil halaman baru tadi
      ),
    );
  },
  child: Card(
          color: const Color(0xFF2C2C2E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Buku
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.thumbnailUrl,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        Container(width: 70, height: 100, color: Colors.grey, child: const Icon(Icons.broken_image)),
                  ),
                ),
                const SizedBox(width: 16),
                // Detail Buku
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authors,
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.publishedDate,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
  ),
        );

      },
    );
  }
}