import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedMonth = "3월";
  final List<String> months = ["1월", "2월", "3월", "4월", "5월"];

  final List<Map<String, String>> records = [
    {
      "date": "3/12",
      "sentence": "버틴 날이 나를 강하게 만든다.",
      "book": "아침 그리고 시작",
    },
    {
      "date": "3/10",
      "sentence": "꾸준함이 최고의 속도다.",
      "book": "평범함의 힘",
    },
    {
      "date": "3/09",
      "sentence": "시선보다 기준이 중요하다.",
      "book": "보통의 용기",
    },
    {
      "date": "3/07",
      "sentence": "오늘 시작하는 사람이 결국 이긴다.",
      "book": "오늘부터 나답게",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "히스토리",
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
          Row(
            children: [
              Text(
                selectedMonth,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => Container(
                      height: 260,
                      color: Colors.white,
                      child: CupertinoPicker(
                        itemExtent: 38,
                        onSelectedItemChanged: (index) {
                          setState(() => selectedMonth = months[index]);
                        },
                        children: months
                            .map(
                              (m) => Center(
                                child: Text(
                                  m,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            "이번 달 북스타그램 ✨",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 14),

          ...records.map((r) {
            return Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 4),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r["date"]!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\"${r["sentence"]!}\"",
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "📖 ${r["book"]!}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF667EEA),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 4),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📊 이번 달 통계",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  "• 12개의 문장 기록",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  "• 7일 연속 기록 중 🔥",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  "• 가장 많이 읽은 책: 『아침 그리고 시작』",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
