class BookSearchResult {
  const BookSearchResult({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.isbn,
    this.link,
  });

  final String title;
  final String author;
  final String imageUrl;
  final String isbn;
  final String? link;

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    final rawTitle = json['title'] as String? ?? '';
    final rawAuthor = json['author'] as String? ?? '';
    final sanitizedTitle = rawTitle.replaceAll(RegExp(r'<[^>]*>'), '');
    final sanitizedAuthor = rawAuthor.replaceAll(RegExp(r'<[^>]*>'), '');
    final imageFromCover = json['cover'] as String?;
    final imageFromImage = json['image'] as String?;
    final isbnValue =
        (json['isbn13'] as String?)?.trim().isNotEmpty == true
            ? json['isbn13'] as String
            : json['isbn'] as String? ?? '';

    return BookSearchResult(
      title: sanitizedTitle,
      author: sanitizedAuthor,
      imageUrl: imageFromCover?.isNotEmpty == true
          ? imageFromCover!
          : (imageFromImage ?? ''),
      isbn: isbnValue,
      link: json['link'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookSearchResult &&
          runtimeType == other.runtimeType &&
          isbn == other.isbn &&
          title == other.title &&
          author == other.author;

  @override
  int get hashCode => Object.hash(title, author, isbn);
}
