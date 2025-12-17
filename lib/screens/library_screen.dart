import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_book.dart';
import '../services/user_book_service.dart';
import 'book_detail_screen.dart';
import 'book_registration_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final UserBookService _userBookService = const UserBookService();

  List<UserBook> _userBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserBooks();
  }

  Future<void> _loadUserBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _userBookService.fetchUserBooks();
      if (!mounted) return;
      setState(() {
        _userBooks = books;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "내 서재 정보를 불러오지 못했어요.";
        _userBooks = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatGoalDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return "${date.year}.$month.$day";
  }

  Future<void> _openBookRegistration() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const BookRegistrationScreen()),
    );

    if (!mounted) return;
    if (result != null) {
      await _loadUserBooks();
    }
  }

  Future<void> _openBookDetail(int index) async {
    final book = _userBooks[index];
    final shouldRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    );

    if (shouldRefresh == true && mounted) {
      await _loadUserBooks();
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openBookRegistration,
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_isLoading)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _loadUserBooks(),
                    child: const Text("다시 시도"),
                  ),
                ],
              ),
            )
          else if (_userBooks.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 48,
                    color: Color(0xFF8E8E93),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "아직 등록된 책이 없어요.",
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._userBooks.asMap().entries.map((entry) {
              final book = entry.value;
              final index = entry.key;
              final int progressPercent = book.progressPercent;
              final double progressRatio = book.progressRatio;
              final DateTime? goalDate = book.goalDate;
              final String coverUrl = book.coverUrl;

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
                        child: coverUrl.isEmpty
                            ? Container(
                                width: 64,
                                height: 88,
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.grey,
                                ),
                              )
                            : Image.network(
                                coverUrl,
                                width: 64,
                                height: 88,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 64,
                                    height: 88,
                                    alignment: Alignment.center,
                                    color: Colors.grey.shade200,
                                    child: const CupertinoActivityIndicator(),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
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
                              book.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
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
                                  widthFactor: progressRatio,
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
                            const SizedBox(height: 6),
                            Text(
                              "$progressPercent% 읽는 중",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                            if (goalDate != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                "${_formatGoalDate(goalDate)} 완독 예정",
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
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
