import 'package:ewalletdemo/Screens/auth/login.dart';
import 'package:ewalletdemo/Screens/business_auth/business_login.dart';
import 'package:flutter/material.dart';

class AccountsLayout extends StatelessWidget {
  const AccountsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: const Text('Bireysel Kullanıcı Hesabı'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BusinessLogin()),
                );
              },
              child: const Text('İşletme Hesabı'),
            ),
          ],
        ),
      ),
    );
  }
}
