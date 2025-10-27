import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class StorageService {
  static const String _booksKey = 'books';

  Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getString(_booksKey);
    if (booksJson == null) return [];

    final List<dynamic> decoded = jsonDecode(booksJson);
    return decoded.map((json) => Book.fromJson(json)).toList();
  }

  Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = jsonEncode(books.map((b) => b.toJson()).toList());
    await prefs.setString(_booksKey, booksJson);
  }
}
