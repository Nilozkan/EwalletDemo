import 'package:ewalletdemo/Screens/home/home_screen.dart';
import 'package:ewalletdemo/Screens/home/profile_screen.dart';
import 'package:ewalletdemo/Screens/home/qr_scanner.dart';
import 'package:flutter/material.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    print("Main selected page: $selectedPage");
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        toolbarHeight: 90,
      ),
      body: selectedPage == 0
          ? const HomeScreen()
          : selectedPage == 1
              ? const QRScanner()
              : selectedPage == 2
                  ? const EditProfileScreen()
                  : const HomeScreen(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text('Settings'),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white, // Taban çubuğunun arka plan rengi
      selectedItemColor: Colors.purple, // Seçili öğelerin rengi
      unselectedItemColor: Colors.grey, // Seçili olmayan öğelerin rengi
      selectedLabelStyle: const TextStyle(color: Colors.red),
      currentIndex: selectedPage,
      onTap: (value) {
        setState(() {
          selectedPage = value;
        });
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'QR',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
