import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book_search_result.dart';
import '../services/book_search_service.dart';

class BookRegistrationScreen extends StatefulWidget {
  const BookRegistrationScreen({super.key});

  @override
  State<BookRegistrationScreen> createState() => _BookRegistrationScreenState();
}

class _BookRegistrationScreenState extends State<BookRegistrationScreen> {
  static const String _defaultQuery = "클린코드";

  final TextEditingController _searchController = TextEditingController();
  final BookSearchService _bookSearchService = const BookSearchService();

  final List<BookSearchResult> _books = [];
  BookSearchResult? _selectedBook;
  String _query = "";
  DateTime? _goalDate;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _query = _defaultQuery;
    _searchController.text = _defaultQuery;
    _fetchBooks(_query);
  }

  void _onSelectBook(BookSearchResult book) {
    setState(() => _selectedBook = book);
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final trimmed = value.trim();
      if (!mounted) return;

      if (trimmed.isEmpty) {
        setState(() {
          _books.clear();
          _errorMessage = null;
          _selectedBook = null;
        });
        return;
      }

      _fetchBooks(trimmed);
    });
  }

  Future<void> _fetchBooks(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _bookSearchService.searchBooks(query);
      if (!mounted) return;
      setState(() {
        _books
          ..clear()
          ..addAll(results);
        if (_selectedBook != null && !_books.contains(_selectedBook)) {
          _selectedBook = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "도서 정보를 불러오지 못했어요.";
        _books.clear();
        _selectedBook = null;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSearchResult(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(
        child: Text(
          "검색 결과가 없습니다",
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _books.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = _books[index];
        final bool isSelected = _selectedBook == book;
        return ListTile(
          onTap: () => _onSelectBook(book),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.imageUrl.isEmpty
                ? Container(
                    width: 52,
                    height: 72,
                    color: const Color(0xFFF2F2F7),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF8E8E93),
                    ),
                  )
                : Image.network(
                    book.imageUrl,
                    width: 52,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 72,
                      color: const Color(0xFFF2F2F7),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
          ),
          title: Text(
            book.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.4,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle_rounded,
                  color: theme.primaryColor,
                )
              : const Icon(
                  Icons.circle_outlined,
                  color: Color(0xFFD1D1D6),
                ),
        );
      },
    );
  }

  Future<void> _pickGoalDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _goalDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (picked != null) {
      setState(() => _goalDate = picked);
    }
  }

  void _onConfirm() {
    if (_selectedBook == null || _goalDate == null) return;
    Navigator.of(context).pop({
      "title": _selectedBook!.title,
      "author": _selectedBook!.author,
      "cover": _selectedBook!.imageUrl,
      "progress": 0,
      "pages": 300,
      "currentPage": 0,
      "goalDate": _goalDate,
      "notes": <Map<String, dynamic>>[],
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: const Text(
          "새 책 등록",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: "책 제목을 검색하세요",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _buildSearchResult(theme),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child:
                    isKeyboardVisible
                        ? const SizedBox.shrink(key: ValueKey('keyboard-visible'))
                        : Column(
                          key: const ValueKey('goal-section'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              "완독 목표",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickGoalDate,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "완독 목표 날짜",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF8E8E93),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _goalDate == null
                                              ? "날짜를 선택하세요"
                                              : "${_goalDate!.year}.${_goalDate!.month.toString().padLeft(2, '0')}.${_goalDate!.day.toString().padLeft(2, '0')}",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                _goalDate == null
                                                    ? const Color(0xFF8E8E93)
                                                    : const Color(0xFF1C1C1E),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.calendar_month_rounded,
                                      color: Color(0xFF667EEA),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _selectedBook == null || _goalDate == null
                                        ? null
                                        : _onConfirm,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color(0xFF667EEA),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "확인",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
