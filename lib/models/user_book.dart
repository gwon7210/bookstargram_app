class UserBook {
  const UserBook({
    required this.id,
    required this.title,
    required this.author,
    required this.pageCount,
    required this.coverUrl,
    required this.status,
    required this.currentPage,
    this.goalDate,
    this.startedAt,
    this.finishedAt,
  });

  final String id;
  final String title;
  final String author;
  final int pageCount;
  final String coverUrl;
  final String status;
  final int currentPage;
  final DateTime? goalDate;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  factory UserBook.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return UserBook(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      pageCount: json['pageCount'] as int? ?? 0,
      coverUrl: json['coverUrl'] as String? ?? '',
      status: json['status'] as String? ?? '',
      currentPage: json['currentPage'] as int? ?? 0,
      goalDate: _parseDate(json['goalDate']),
      startedAt: _parseDate(json['startedAt']),
      finishedAt: _parseDate(json['finishedAt']),
    );
  }

  UserBook copyWith({
    int? currentPage,
    DateTime? goalDate,
    bool updateGoalDate = false,
  }) {
    return UserBook(
      id: id,
      title: title,
      author: author,
      pageCount: pageCount,
      coverUrl: coverUrl,
      status: status,
      currentPage: currentPage ?? this.currentPage,
      goalDate: updateGoalDate ? goalDate : (goalDate ?? this.goalDate),
      startedAt: startedAt,
      finishedAt: finishedAt,
    );
  }

  int get progressPercent {
    if (pageCount <= 0) return 0;
    final double ratio = currentPage / pageCount;
    final int percent = (ratio * 100).round();
    if (percent < 0) return 0;
    if (percent > 100) return 100;
    return percent;
  }

  double get progressRatio {
    if (pageCount <= 0) return 0;
    final double ratio = currentPage / pageCount;
    if (ratio.isNaN || ratio.isInfinite) return 0;
    return ratio.clamp(0, 1);
  }
}
