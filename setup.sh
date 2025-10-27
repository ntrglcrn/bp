#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📚 Создание структуры Book Reader App...${NC}\n"

# Создание папок
echo -e "${GREEN}Создание папок...${NC}"
mkdir -p lib/models
mkdir -p lib/providers
mkdir -p lib/services
mkdir -p lib/screens

# Создание pubspec.yaml
echo -e "${GREEN}Создание pubspec.yaml...${NC}"
cat > pubspec.yaml << 'EOF'
name: bp
description: Book reader application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  provider: ^6.1.1
  file_picker: ^6.1.1
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
EOF

# Создание lib/models/book.dart
echo -e "${GREEN}Создание lib/models/book.dart...${NC}"
cat > lib/models/book.dart << 'EOF'
class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String coverUrl;
  final int currentPage;
  final int totalPages;
  final DateTime lastRead;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    this.coverUrl = '',
    this.currentPage = 0,
    this.totalPages = 0,
    required this.lastRead,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? filePath,
    String? coverUrl,
    int? currentPage,
    int? totalPages,
    DateTime? lastRead,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath ?? this.filePath,
      coverUrl: coverUrl ?? this.coverUrl,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastRead: lastRead ?? this.lastRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'filePath': filePath,
        'coverUrl': coverUrl,
        'currentPage': currentPage,
        'totalPages': totalPages,
        'lastRead': lastRead.toIso8601String(),
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'],
        title: json['title'],
        author: json['author'],
        filePath: json['filePath'],
        coverUrl: json['coverUrl'] ?? '',
        currentPage: json['currentPage'] ?? 0,
        totalPages: json['totalPages'] ?? 0,
        lastRead: DateTime.parse(json['lastRead']),
      );
}
EOF

# Создание lib/services/storage_service.dart
echo -e "${GREEN}Создание lib/services/storage_service.dart...${NC}"
cat > lib/services/storage_service.dart << 'EOF'
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
EOF

# Создание lib/providers/book_provider.dart
echo -e "${GREEN}Создание lib/providers/book_provider.dart...${NC}"
cat > lib/providers/book_provider.dart << 'EOF'
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
EOF

# Создание lib/screens/reader_screen.dart
echo -e "${GREEN}Создание lib/screens/reader_screen.dart...${NC}"
cat > lib/screens/reader_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import '../models/book.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Открыть настройки чтения
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64),
            const SizedBox(height: 16),
            const Text('Reader implementation'),
            const SizedBox(height: 8),
            Text(
              'File: ${widget.book.filePath}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Создание lib/screens/library_screen.dart
echo -e "${GREEN}Создание lib/screens/library_screen.dart...${NC}"
cat > lib/screens/library_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import 'reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BookProvider>().loadBooks());
  }

  Future<void> _pickBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf', 'txt'],
    );

    if (result != null && mounted) {
      final file = result.files.first;
      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: file.name.split('.').first,
        author: 'Unknown',
        filePath: file.path!,
        lastRead: DateTime.now(),
      );

      await context.read<BookProvider>().addBook(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        elevation: 0,
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          if (provider.books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No books yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first book to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.books.length,
            itemBuilder: (context, index) {
              final book = provider.books[index];
              return BookCard(book: book);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickBook,
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderScreen(book: book),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.book,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.currentPage > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: book.totalPages > 0
                          ? book.currentPage / book.totalPages
                          : 0,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Создание lib/main.dart
echo -e "${GREEN}Создание lib/main.dart...${NC}"
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/library_screen.dart';
import 'providers/book_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: MaterialApp(
        title: 'Book Reader',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LibraryScreen(),
      ),
    );
  }
}
EOF

echo -e "\n${BLUE}✅ Структура создана успешно!${NC}"
echo -e "\n${GREEN}Следующие шаги:${NC}"
echo "1. flutter pub get"
echo "2. flutter run"
echo -e "\n${BLUE}Структура проекта:${NC}"
echo "lib/"
echo "├── models/"
echo "│   └── book.dart"
echo "├── providers/"
echo "│   └── book_provider.dart"
echo "├── services/"
echo "│   └── storage_service.dart"
echo "├── screens/"
echo "│   ├── library_screen.dart"
echo "│   └── reader_screen.dart"
echo "└── main.dart"
