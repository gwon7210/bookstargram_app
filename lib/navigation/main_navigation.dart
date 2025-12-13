import 'package:flutter/material.dart';

import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  static const routeName = '/main';

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
          BottomNavigationBarItem(
            icon: Icon(Icons.today_rounded),
            label: "오늘",
          ),
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
