import 'package:ewalletdemo/Screens/qr_screen/generate_qr_code.dart';
import 'package:ewalletdemo/Screens/qr_screen/scan_qr_code.dart';
import 'package:flutter/material.dart';

import 'phone_payment_screen.dart'; // Yeni ekranı içe aktarın

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Qr',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple.shade300,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ScanQRCode()));
                  });
                },
                child: const Text('QR okut')),
            const SizedBox(
              height: 48,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const GenerateQRCode()));
                  });
                },
                child: const Text('QR oluştur')),
            const SizedBox(
              height: 48,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PhonePaymentScreen()));
                  });
                },
                child:
                    const Text('Telefon Numarası ile Ödeme Yap')), // Yeni buton
          ],
        ),
      ),
    );
  }
}
