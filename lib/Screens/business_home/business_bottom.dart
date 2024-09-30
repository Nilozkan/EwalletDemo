import 'package:flutter/material.dart';

import 'business_home_layout.dart';
import 'menu.dart';

class BusinessBottom extends StatefulWidget {
  const BusinessBottom({super.key});

  @override
  State<BusinessBottom> createState() => _BusinessBottomState();
}

class _BusinessBottomState extends State<BusinessBottom> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BusinessHomeLayout(),
    const Menu(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
