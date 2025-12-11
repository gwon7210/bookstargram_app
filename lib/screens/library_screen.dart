import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'book_detail_screen.dart';
import 'book_registration_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Map<String, dynamic>> _libraryBooks = [
    {
      "title": "아주 작은 습관의 힘",
      "author": "제임스 클리어",
      "progress": 72,
      "currentPage": 230,
      "pages": 320,
      "cover":
          "https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=400&q=80",
      "goalDate": DateTime.now().add(const Duration(days: 14)),
      "notes": [
        {
          "text": "작은 단계라도 꾸준히!",
          "page": 120,
          "date": DateTime.now().subtract(const Duration(days: 2)),
        },
      ],
    },
    {
      "title": "어린 왕자",
      "author": "앙투안 드 생텍쥐페리",
      "progress": 100,
      "currentPage": 180,
      "pages": 180,
      "cover":
          "https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=400&q=80",
      "goalDate": DateTime.now(),
      "notes": const [],
    },
    {
      "title": "부의 인문학",
      "author": "브라운스톤",
      "progress": 35,
      "currentPage": 147,
      "pages": 420,
      "cover":
          "https://images.unsplash.com/photo-1495446815901-a7297e633e8d?auto=format&fit=crop&w=400&q=80",
      "goalDate": DateTime.now().add(const Duration(days: 30)),
      "notes": const [],
    },
  ];

  String _formatGoalDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return "${date.year}.$month.$day";
  }

  Future<void> _openBookRegistration() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const BookRegistrationScreen()),
    );

    if (result != null) {
      setState(() {
        _libraryBooks.insert(0, {
          ...result,
          "progress": result["progress"] ?? 0,
          "pages": result["pages"] ?? 300,
          "currentPage": result["currentPage"] ?? 0,
          "goalDate": result["goalDate"],
          "notes": result["notes"] ?? [],
        });
      });
    }
  }

  Future<void> _openBookDetail(int index) async {
    final book = _libraryBooks[index];
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );

    if (result != null) {
      setState(() {
        _libraryBooks[index] = {
          ...book,
          "currentPage": result["currentPage"],
          "progress": result["progress"],
          "goalDate": result["goalDate"] ?? book["goalDate"],
          "notes": result["notes"] ?? book["notes"],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "내 서재",
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "최근 추가한 책",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          ..._libraryBooks.asMap().entries.map((entry) {
            final book = entry.value;
            final index = entry.key;
            final int progress = book["progress"] as int;
            final DateTime? goalDate = book["goalDate"] as DateTime?;
            return GestureDetector(
              onTap: () => _openBookDetail(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, 3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        book["cover"] as String,
                        width: 64,
                        height: 88,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            width: 64,
                            height: 88,
                            alignment: Alignment.center,
                            color: Colors.grey.shade200,
                            child: const CupertinoActivityIndicator(),
                          );
                        },
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 64,
                              height: 88,
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book["title"] as String,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book["author"] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E93),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress / 100,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$progress% 완료",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667EEA),
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (goalDate != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              "${_formatGoalDate(goalDate)} 완독 목표",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "기록",
                        style: TextStyle(
                          color: Color(0xFF667EEA),
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _openBookRegistration,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "새 책 등록하기",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "읽고 싶은 책을 서재에 추가해 보세요.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF8E8E93),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
