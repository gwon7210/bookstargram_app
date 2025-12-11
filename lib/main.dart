import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> get _pages => const [
    HomeScreen(),
    LibraryScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    // Hot-reload 안전: 기존 인덱스가 페이지 수보다 크면 0으로 리셋
    final int safeIndex = _currentIndex >= pages.length ? 0 : _currentIndex;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF667EEA),
        unselectedItemColor: const Color(0xFF8E8E93),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today_rounded), label: "오늘"),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: "내 서재",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline_rounded),
            label: "히스토리",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: "설정",
          ),
        ],
      ),
    );
  }
}
