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
