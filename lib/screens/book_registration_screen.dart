import 'package:flutter/material.dart';

class BookRegistrationScreen extends StatefulWidget {
  const BookRegistrationScreen({super.key});

  @override
  State<BookRegistrationScreen> createState() => _BookRegistrationScreenState();
}

class _BookRegistrationScreenState extends State<BookRegistrationScreen> {
  final TextEditingController _searchController = TextEditingController();

  Map<String, String>? _selectedBook;
  String _query = "";
  DateTime? _goalDate;

  final List<Map<String, String>> _bookDatabase = [
    {
      "title": "미드나잇 라이브러리",
      "author": "매트 헤이그",
      "pages": "320",
      "cover":
          "https://images.unsplash.com/photo-1529655683826-aba9b3e77383?auto=format&fit=crop&w=400&q=80",
    },
    {
      "title": "달러구트 꿈 백화점",
      "author": "이미예",
      "pages": "280",
      "cover":
          "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?auto=format&fit=crop&w=400&q=80",
    },
    {
      "title": "불편한 편의점",
      "author": "김호연",
      "pages": "300",
      "cover":
          "https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=400&q=80",
    },
    {
      "title": "공간의 미래",
      "author": "유현준",
      "pages": "360",
      "cover":
          "https://images.unsplash.com/photo-1463320898484-cdee8141c787?auto=format&fit=crop&w=400&q=80",
    },
    {
      "title": "데일 카네기 인간관계론",
      "author": "데일 카네기",
      "pages": "400",
      "cover":
          "https://images.unsplash.com/photo-1529655683826-aba9b3e77383?auto=format&fit=crop&w=400&q=80",
    },
    {
      "title": "트렌드 코리아 2024",
      "author": "김난도",
      "pages": "450",
      "cover":
          "https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=400&q=80",
    },
  ];

  List<Map<String, String>> get _filteredBooks {
    if (_query.isEmpty) return _bookDatabase;
    return _bookDatabase
        .where(
          (book) => book["title"]!.toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();
  }

  void _onSelectBook(Map<String, String> book) {
    setState(() => _selectedBook = book);
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
      "title": _selectedBook!["title"],
      "author": _selectedBook!["author"],
      "cover": _selectedBook!["cover"],
      "progress": 0,
      "pages": int.tryParse(_selectedBook!["pages"] ?? "") ?? 300,
      "currentPage": 0,
      "goalDate": _goalDate,
      "notes": <Map<String, dynamic>>[],
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredBooks = _filteredBooks;

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
                onChanged: (value) => setState(() => _query = value),
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
                  child:
                      filteredBooks.isEmpty
                          ? const Center(
                            child: Text(
                              "검색 결과가 없습니다",
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          : ListView.separated(
                            itemCount: filteredBooks.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];
                              final bool isSelected = _selectedBook == book;
                              return ListTile(
                                onTap: () => _onSelectBook(book),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                title: Text(
                                  book["title"]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1C1C1E),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                subtitle: Text(
                                  book["author"]!,
                                  style: const TextStyle(
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                                trailing:
                                    isSelected
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
