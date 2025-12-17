class FeelingEntry {
  final String text;
  final DateTime recordedAt;
  final int? pageNumber;
  final String? userId;
  final String? userBookId;

  const FeelingEntry({
    required this.text,
    required this.recordedAt,
    this.pageNumber,
    this.userId,
    this.userBookId,
  });

  factory FeelingEntry.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String? raw) {
      if (raw == null || raw.isEmpty) {
        return DateTime.now();
      }
      return DateTime.tryParse(raw) ?? DateTime.now();
    }

    return FeelingEntry(
      text: (json['text'] as String?)?.trim() ?? '',
      recordedAt: parseDate(json['recordedAt'] as String?),
      pageNumber: json['pageNumber'] as int?,
      userId: json['userId'] as String?,
      userBookId: json['userBookId'] as String?,
    );
  }
}
