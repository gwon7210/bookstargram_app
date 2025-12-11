import 'package:flutter/material.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final TextEditingController _pageController;
  final TextEditingController _feelingController = TextEditingController();
  DateTime? _goalDate;
  List<Map<String, dynamic>> _feelings = [];

  int get _totalPages => (widget.book["pages"] as int?) ?? 1;

  @override
  void initState() {
    super.initState();
    final int initialPage = (widget.book["currentPage"] as int?) ?? 0;
    _pageController = TextEditingController(text: initialPage.toString());
    _goalDate = widget.book["goalDate"] as DateTime?;
    final rawNotes = widget.book["notes"] as List<dynamic>? ?? [];
    _feelings =
        rawNotes
            .map((note) {
              if (note is Map<String, dynamic>) {
                return Map<String, dynamic>.from(note);
              }
              if (note is Map) {
                return Map<String, dynamic>.from(note.cast<String, dynamic>());
              }
              return <String, dynamic>{};
            })
            .where((note) => note.isNotEmpty)
            .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _feelingController.dispose();
    super.dispose();
  }

  void _saveProgress() {
    final entered = int.tryParse(_pageController.text.trim()) ?? 0;
    final int clamped = entered.clamp(0, _totalPages);
    final int progress = ((clamped / _totalPages) * 100).round();

    Navigator.of(context).pop({
      "currentPage": clamped,
      "progress": progress,
      "goalDate": _goalDate,
      "notes": _feelings,
    });
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

  void _addFeeling() {
    final text = _feelingController.text.trim();
    if (text.isEmpty) return;
    final entered = int.tryParse(_pageController.text.trim()) ?? 0;
    final pageSnapshot = entered.clamp(0, _totalPages);

    setState(() {
      _feelings.insert(0, {
        "text": text,
        "page": pageSnapshot,
        "date": DateTime.now(),
      });
      _feelingController.clear();
    });
  }

  void _removeFeeling(int index) {
    if (index < 0 || index >= _feelings.length) return;
    setState(() {
      _feelings.removeAt(index);
    });
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "${date.year}.$month.$day";
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

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
                              child: Image.network(
                                book["cover"] as String,
                                width: 80,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book["title"] as String,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1C1C1E),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book["author"] as String,
                                    style: const TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "총 $_totalPages 페이지",
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
                      const Text(
                        "한줄 느낌",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
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
                            TextField(
                              controller: _feelingController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                hintText: "오늘의 느낌을 한 줄로 남겨보세요",
                                border: InputBorder.none,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _addFeeling,
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text("추가"),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF667EEA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_feelings.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E5EA)),
                          ),
                          child: const Center(
                            child: Text(
                              "아직 작성된 한줄 느낌이 없어요.",
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          children:
                              _feelings.asMap().entries.map((entry) {
                                final index = entry.key;
                                final note = entry.value;
                                final DateTime? date =
                                    note["date"] as DateTime?;
                                final int page = note["page"] as int? ?? 0;
                                final String formattedDate =
                                    date != null ? _formatDate(date) : "";
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              note["text"] as String? ?? "",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1C1C1E),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "$page페이지 · $formattedDate",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF8E8E93),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeFeeling(index),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Color(0xFFFF3B30),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
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
                                blurRadius: 10,
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
                                    "목표 날짜",
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProgress,
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
