import 'package:flutter/material.dart';
import 'book_model.dart';
import 'create_challenge.dart'; // Import halaman bikin challenge

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

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
        title: const Text(
          'Detail Buku',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Cover Besar
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book.thumbnailUrl,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    width: 160,
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Judul & Penulis
            Text(
              book.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                book.authors,
                style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),

            // 3. Tombol Aksi (Create Challenge)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigasi ke CreateChallengePage dengan membawa data buku
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateChallengePage(
                        initialTitle: "Baca Buku: ${book.title}",
                        initialDescription:
                            "Tantangan menyelesaikan buku '${book.title}' karya ${book.authors}. Yuk join!",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_task, color: Colors.white),
                label: const Text(
                  "Jadikan Challenge",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 4. Deskripsi
            const Text(
              "Deskripsi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              book.description,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
