import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhonePaymentScreen extends StatefulWidget {
  const PhonePaymentScreen({super.key});

  @override
  State<PhonePaymentScreen> createState() => _PhonePaymentScreenState();
}

class _PhonePaymentScreenState extends State<PhonePaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<void> _makePayment() async {
    final String phoneNumber = _phoneController.text.trim();
    final double amount = double.parse(_amountController.text.trim());

    // Geçerli kullanıcının belgesini al
    final user = FirebaseAuth.instance.currentUser;
    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    final currentUserSnapshot = await currentUserRef.get();

    if (!currentUserSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli kullanıcı bulunamadı!')),
      );
      return;
    }

    final currentBalance = currentUserSnapshot['balance'].toDouble();
    if (currentBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye!')),
      );
      return;
    }

    // Alıcıyı telefon numarasına göre bul
    final recipientSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (recipientSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alıcı bulunamadı!')),
      );
      return;
    }

    final recipientDoc = recipientSnapshot.docs.first;
    final recipientRef = recipientDoc.reference;
    final recipientBalance = recipientDoc['balance'].toDouble();

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(currentUserRef, {'balance': currentBalance - amount});
      transaction.update(recipientRef, {'balance': recipientBalance + amount});

      // Gönderici için işlem geçmişini kaydet
      transaction
          .set(FirebaseFirestore.instance.collection('hesapozgecmisi').doc(), {
        'userId': user.uid,
        'amount': amount,
        'type': 'paid',
        'date': FieldValue.serverTimestamp(),
      });

      // Alıcı için işlem geçmişini kaydet
      transaction
          .set(FirebaseFirestore.instance.collection('hesapozgecmisi').doc(), {
        'userId': recipientDoc.id,
        'amount': amount,
        'type': 'Ödeme alındı',
        'date': FieldValue.serverTimestamp(),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ödeme başarılı!')),
    );

    _phoneController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telefon Numarası ile Ödeme Yap'),
        backgroundColor: Colors.deepPurple.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Ödeme Miktarı',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _makePayment,
              child: const Text('Ödeme Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
