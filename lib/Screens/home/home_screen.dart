import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  double _balance = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _getUserBalance();
    // Belirli aralıklarla bakiyenin güncellenmesi için Timer kullanımı
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _getUserBalance();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Timer'ı dispose içinde iptal et
    super.dispose();
  }

  Future<void> _getUserBalance() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(_user.uid).get();
        if (userDoc.exists) {
          var balance = userDoc['balance']; // Değişken olarak alın
          setState(() {
            _balance = balance.toDouble(); // Değeri double olarak al
          });
        }
      } catch (e) {
        print('Error getting user balance: $e');
      }
    }
  }

  Future<void> _updateUserBalance(double amount) async {
    if (_user != null) {
      try {
        double previousBalance = _balance; // Önceki bakiyeyi saklayalım
        await _firestore.collection('users').doc(_user.uid).update({
          'balance': FieldValue.increment(amount),
        });
        await _getUserBalance(); // Güncel bakiyeyi tekrar al
        double newBalance = _balance; // Yeni bakiyeyi alalım
        double balanceChange =
            newBalance - previousBalance; // Değişiklik miktarını hesapla
        await _addTransactionHistory(
            balanceChange); // Yeni işlem geçmişi ekleyelim
      } catch (e) {
        print('Error updating user balance: $e');
      }
    }
  }

  Future<void> _addTransactionHistory(double amount) async {
    if (_user != null) {
      try {
        await _firestore.collection('hesapozgecmisi').add({
          'userId': _user.uid,
          'amount': amount.toStringAsFixed(2), // Sayıyı string olarak kaydet
          'type': amount > 0 ? 'received' : 'spent', // Türü belirle
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error adding transaction history: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Güncel bakiye section
        Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          height: 160,
          width: 350,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Güncel Bakiye',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
                Text('$_balance TL',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25), // Araya boşluk ekledik
        const Align(
          alignment: Alignment.centerLeft, // Metni sola dayalı hale getiriyoruz
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Hesap Hareketleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start, // Metni sola dayalı yapar
            ),
          ),
        ),
        const SizedBox(height: 10), // Araya boşluk ekledik
        _user == null
            ? const SizedBox()
            : Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('hesapozgecmisi')
                      .where('userId', isEqualTo: _user.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print('Snapshot Error Ozgecmis: ${snapshot.error}');
                      return const Center(child: Text('Bir hata oluştu.'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      print('Veri Yok veya Boş');
                      return const Center(
                          child: Text('Henüz işlem geçmişi yok.'));
                    }
                    final transactions = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final userId = transaction['userId'] as String;
                        if (userId != _user.uid) return const SizedBox();
                        final amount = transaction['amount'] != null
                            ? double.parse(transaction['amount'].toString())
                            : 0.0;
                        final type = transaction['type'] != null
                            ? transaction['type'].toString()
                            : '';
                        final timestamp = transaction['date'] as Timestamp?;
                        final date = timestamp != null
                            ? timestamp.toDate().toString()
                            : 'Zaman bilgisi yok';
                        return ListTile(
                          leading: const Icon(Icons.money),
                          title: Text(
                              '₺$amount ${type == "paid" ? "Ödeme yapıldı" : "Ödeme alındı"}'),
                          subtitle: Text(date),
                        );
                      },
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required double amount,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(icon),
          color: color,
          onPressed: () => _updateUserBalance(amount),
        ),
        Text(label),
      ],
    );
  }
}
