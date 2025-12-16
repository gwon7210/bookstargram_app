import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book_search_result.dart';
import '../services/book_search_service.dart';
import '../services/user_book_service.dart';

class BookRegistrationScreen extends StatefulWidget {
  const BookRegistrationScreen({super.key});

  @override
  State<BookRegistrationScreen> createState() => _BookRegistrationScreenState();
}

class _BookRegistrationScreenState extends State<BookRegistrationScreen> {
  static const String _defaultQuery = "클린코드";
  static const int _searchStep = 0;
  static const int _goalStep = 1;

  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  final BookSearchService _bookSearchService = const BookSearchService();
  final UserBookService _userBookService = const UserBookService();

  final List<BookSearchResult> _books = [];
  BookSearchResult? _selectedBook;
  String _query = "";
  DateTime? _goalDate;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;
  bool _isSubmitting = false;
  int _currentStep = _searchStep;

  @override
  void initState() {
    super.initState();
    _query = _defaultQuery;
    _searchController.text = _defaultQuery;
    _fetchBooks(_query);
  }

  void _onSelectBook(BookSearchResult book) {
    setState(() {
      _selectedBook = book;
      if (_currentStep == _goalStep) {
        _goalDate = null;
      }
    });
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

  Future<void> _onConfirm() async {
    if (_selectedBook == null || _goalDate == null || _isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      await _userBookService.registerBook(
        book: _selectedBook!,
        goalDate: _goalDate!,
      );

      if (!mounted) return;
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
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _goToSearchStep() {
    setState(() => _currentStep = _searchStep);
    _pageController.animateToPage(
      _searchStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _goToGoalStep() async {
    if (_selectedBook == null) return;
    setState(() => _currentStep = _goalStep);
    await _pageController.animateToPage(
      _goalStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isSearchStep = _currentStep == _searchStep;

    return WillPopScope(
      onWillPop: () async {
        if (_currentStep == _goalStep) {
          _goToSearchStep();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1C1C1E),
          elevation: 0,
          title: Text(
            isSearchStep ? "새 책 찾기" : "완독 목표 설정",
            style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSearchStep(theme),
                      _buildGoalStep(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isSearchStep
                            ? (_selectedBook == null ? null : _goToGoalStep)
                            : (_selectedBook == null || _goalDate == null || _isSubmitting
                                ? null
                                : _onConfirm),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF667EEA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        isSearchStep
                            ? const Text(
                                "다음",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "등록",
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
        ),
      ),
    );
  }

  Widget _buildSearchStep(ThemeData theme) {
    return Column(
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
      ],
    );
  }

  Widget _buildGoalStep() {
    final book = _selectedBook;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (book != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        book.imageUrl.isEmpty
                            ? Container(
                                width: 64,
                                height: 88,
                                color: const Color(0xFFF2F2F7),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: Color(0xFF8E8E93),
                                ),
                              )
                            : Image.network(
                                book.imageUrl,
                                width: 64,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 88,
                                  color: const Color(0xFFF2F2F7),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    color: Color(0xFF8E8E93),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C1E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E8E93),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        TextButton(
                          onPressed: _goToSearchStep,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF667EEA),
                          ),
                          child: const Text("다른 책 선택하기"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E5EA)),
              ),
              child: const Text(
                "먼저 읽을 책을 선택해주세요.",
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            "완독 목표",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickGoalDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              _goalDate == null ? const Color(0xFF8E8E93) : const Color(0xFF1C1C1E),
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
        ],
      ),
    );
  }
}
