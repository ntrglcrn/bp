import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/storage_service.dart';

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  final StorageService _storage = StorageService();

  List<Book> get books => _books;

  Future<void> loadBooks() async {
    _books = await _storage.loadBooks();
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    _books.add(book);
    await _storage.saveBooks(_books);
    notifyListeners();
  }

  Future<void> updateBookProgress(String bookId, int page) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(
        currentPage: page,
        lastRead: DateTime.now(),
      );
      await _storage.saveBooks(_books);
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    _books.removeWhere((b) => b.id == bookId);
    await _storage.saveBooks(_books);
    notifyListeners();
  }
}
