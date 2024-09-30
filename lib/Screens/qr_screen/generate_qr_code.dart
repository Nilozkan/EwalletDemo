import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRCode extends StatefulWidget {
  const GenerateQRCode({super.key});

  @override
  State<GenerateQRCode> createState() => _GenerateQRCodeState();
}

class _GenerateQRCodeState extends State<GenerateQRCode> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? qrCodeData;

  Future<void> _generateQRCode() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final String amount = _amountController.text.trim();

      if (amount.isNotEmpty) {
        setState(() {
          qrCodeData = '$userId:$amount';
        });

        // Hesap geçmişine QR kodu oluşturma işlemini kaydet
        await _firestore.collection('hesapozgecmisi').add({
          'userId': userId,
          'date': DateTime.now(),
          'amount': double.parse(amount),
          'type': "generated"
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an amount')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter amount',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateQRCode,
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 20),
            if (qrCodeData != null)
              QrImageView(
                data: qrCodeData!,
                version: QrVersions.auto,
                size: 200.0,
              ),
          ],
        ),
      ),
    );
  }
}
