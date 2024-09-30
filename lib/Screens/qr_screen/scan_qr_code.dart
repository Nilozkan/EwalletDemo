import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanQRCode extends StatefulWidget {
  const ScanQRCode({super.key});

  @override
  State<ScanQRCode> createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  String qrResult = 'Scanned data will appear here';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;

      // QR kodundan elde edilen değeri kontrol et
      if (qrCode == '-1') {
        setState(() {
          qrResult = 'QR scan canceled';
        });
        return; // İşlemi iptal et
      }

      setState(() {
        qrResult = qrCode;
      });

      // QR kodundan kullanıcı kimliğini ve miktarı ayıkla
      final parts = qrCode.split(':');
      final String recipientUserId = parts[0];
      final double amount = double.parse(parts[1]);

      // Kullanıcı kimliğini al
      final User? user = _auth.currentUser;
      if (user != null) {
        final String senderUserId = user.uid;

        // Firestore'daki kullanıcı belgelerini güncelle
        await _firestore.runTransaction((transaction) async {
          final senderRef = _firestore.collection('users').doc(senderUserId);
          final recipientRef =
              _firestore.collection('users').doc(recipientUserId);

          final senderSnapshot = await transaction.get(senderRef);
          final recipientSnapshot = await transaction.get(recipientRef);

          if (senderSnapshot.exists && recipientSnapshot.exists) {
            final senderBalance = senderSnapshot['balance'].toDouble();
            final recipientBalance = recipientSnapshot['balance'].toDouble();

            if (senderBalance >= amount) {
              transaction
                  .update(senderRef, {'balance': senderBalance - amount});
              transaction
                  .update(recipientRef, {'balance': recipientBalance + amount});

              // Hesap geçmişi tablosuna kaydet
              await _firestore.collection('hesapozgecmisi').add({
                'userId': senderUserId,
                'date': DateTime.now(),
                'amount': amount,
                'type': "paid"
              });

              setState(() {
                qrResult = '$amount TL payment made.';
              });
            } else {
              setState(() {
                qrResult = 'Insufficient balance!';
              });
            }
          } else {
            setState(() {
              qrResult = 'User not found!';
            });
          }
        });
      } else {
        setState(() {
          qrResult = 'User not found!';
        });
      }
    } on PlatformException {
      setState(() {
        qrResult = 'Failed to read QR';
      });
    } catch (e) {
      setState(() {
        qrResult = 'Error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              qrResult,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(onPressed: scanQR, child: const Text('Scan QR'))
          ],
        ),
      ),
    );
  }
}
