import 'dart:convert';
import 'package:http/http.dart' as http;

/// Data class holding book metadata fetched from Google Books API.
class GoogleBooksResult {
  final String title;
  final String author;
  final String description;
  final String? coverImageUrl;
  final String isbn;

  const GoogleBooksResult({
    required this.title,
    required this.author,
    required this.description,
    this.coverImageUrl,
    required this.isbn,
  });
}

/// Service that queries the Google Books API by ISBN.
class GoogleBooksService {
  final http.Client _client;

  GoogleBooksService() : _client = http.Client();

  void dispose() {
    _client.close();
  }

  /// Looks up a book by ISBN via the Google Books API.
  /// Returns a [GoogleBooksResult] if found, or `null` on no match / error.
  Future<GoogleBooksResult?> lookupByIsbn(String isbn) async {
    try {
      final uri = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn',
      );
      final response = await _client.get(uri);

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final totalItems = data['totalItems'] as int? ?? 0;
      if (totalItems == 0) return null;

      final items = data['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) return null;

      final volumeInfo =
          items[0]['volumeInfo'] as Map<String, dynamic>? ?? {};

      final title = volumeInfo['title'] as String? ?? '';
      if (title.isEmpty) return null;

      final authors = volumeInfo['authors'] as List<dynamic>?;
      final author = authors != null ? authors.join(', ') : '';

      final description = volumeInfo['description'] as String? ?? '';

      // Use Open Library cover URL instead of Google Books thumbnails.
      // Google Books thumbnail URLs lack CORS headers, which breaks
      // Flutter web's CanvasKit renderer. Open Library covers are
      // CORS-friendly and keyed by ISBN.
      final coverUrl = 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg';

      return GoogleBooksResult(
        title: title,
        author: author,
        description: description,
        coverImageUrl: coverUrl,
        isbn: isbn,
      );
    } catch (_) {
      return null;
    }
  }
}
