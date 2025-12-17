import 'package:flutter/material.dart';

import '../models/feeling_entry.dart';
import '../models/user_book.dart';
import '../services/reading_log_service.dart';
import '../services/user_book_service.dart';
import 'reading_log_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final UserBook book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final TextEditingController _pageController;
  final UserBookService _userBookService = const UserBookService();
  final ReadingLogService _readingLogService = const ReadingLogService();
  bool _isSaving = false;
  bool _isLoadingFeelings = false;
  String? _feelingError;
  final List<FeelingEntry> _feelings = [];

  int get _totalPages => widget.book.pageCount;
  int get _clampUpperBound => _totalPages > 0 ? _totalPages : 0;
  int get _displayTotalPages => _totalPages > 0 ? _totalPages : 0;

  @override
  void initState() {
    super.initState();
    final int initialPage = widget.book.currentPage;
    _pageController = TextEditingController(text: initialPage.toString());
    _fetchFeelings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    final entered = int.tryParse(_pageController.text.trim()) ?? 0;
    final int clamped = entered.clamp(0, _clampUpperBound);

    setState(() => _isSaving = true);

    try {
      await _userBookService.updateUserBook(
        id: widget.book.id,
        currentPage: clamped,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  Future<void> _openReadingLog() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReadingLogScreen(book: widget.book),
      ),
    );

    if (!mounted || saved != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("독서 기록을 저장했어요.")),
    );
    await _fetchFeelings();
  }

  Future<void> _fetchFeelings() async {
    setState(() {
      _isLoadingFeelings = true;
      _feelingError = null;
    });

    try {
      final logs = await _readingLogService.fetchFeelings(widget.book.id);
      if (!mounted) return;
      setState(() {
        _feelings
          ..clear()
          ..addAll(logs);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _feelingError = error.toString().replaceFirst('Exception: ', '');
        _feelings.clear();
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingFeelings = false);
    }
  }

  String _formatLogDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year.$month.$day";
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final coverUrl = book.coverUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: const Text(
          "읽기 상태",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  coverUrl.isEmpty
                                      ? Container(
                                          width: 80,
                                          height: 110,
                                          color: Colors.grey.shade200,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.menu_book_rounded,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Image.network(
                                          coverUrl,
                                          width: 80,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80,
                                            height: 110,
                                            color: Colors.grey.shade200,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.menu_book_rounded,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1C1C1E),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book.author,
                                    style: const TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "총 $_displayTotalPages 페이지",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "읽은 페이지",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "전체 페이지",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "$_totalPages",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _pageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "현재 읽은 페이지",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildFeelingsSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _isSaving ? null : _saveProgress,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF1C1C1E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "확인",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _openReadingLog,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1C1C1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: Color(0xFFE5E5EA)),
                      ),
                    ),
                    child: const Text(
                      "독서 기록 남기기",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeelingsSection() {
    Widget buildContent() {
      if (_isLoadingFeelings) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
          ),
        );
      }

      if (_feelingError != null) {
        return Text(
          _feelingError!,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w600,
          ),
        );
      }

      if (_feelings.isEmpty) {
        return const Text(
          "아직 기록이 없어요.",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w600,
          ),
        );
      }

      return _buildFeelingListView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "독서 기록",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 12),
        buildContent(),
      ],
    );
  }

  Widget _buildFeelingListView() {
    final children = _feelings.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatLogDate(entry.recordedAt),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1C1C1E),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }).toList();

    if (_feelings.length <= 4) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    return SizedBox(
      height: 220,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: children,
      ),
    );
  }
}
