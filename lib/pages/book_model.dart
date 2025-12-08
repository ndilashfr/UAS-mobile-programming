class Book {
  final String id;
  final String title;
  final String authors;
  final String description;
  final String thumbnailUrl;
  final String publishedDate;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.thumbnailUrl,
    required this.publishedDate,
  });

  // Factory method untuk parsing JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    
    // Handle list authors yang mungkin kosong
    List<dynamic> authorsList = volumeInfo['authors'] ?? [];
    String authorsStr = authorsList.join(", ");

    // Handle gambar yang mungkin null
    String image = 'https://placehold.co/100x150?text=No+Cover';
    if (volumeInfo['imageLinks'] != null && volumeInfo['imageLinks']['thumbnail'] != null) {
      image = volumeInfo['imageLinks']['thumbnail'];
    }

    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Tanpa Judul',
      authors: authorsStr.isNotEmpty ? authorsStr : 'Penulis Tidak Diketahui',
      description: volumeInfo['description'] ?? 'Tidak ada deskripsi.',
      thumbnailUrl: image,
      publishedDate: volumeInfo['publishedDate'] ?? '-',
    );
  }
}