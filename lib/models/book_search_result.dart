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

    return BookSearchResult(
      title: rawTitle.replaceAll(RegExp(r'<[^>]*>'), ''),
      author: rawAuthor.replaceAll(RegExp(r'<[^>]*>'), ''),
      imageUrl: json['image'] as String? ?? '',
      isbn: json['isbn'] as String? ?? '',
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
