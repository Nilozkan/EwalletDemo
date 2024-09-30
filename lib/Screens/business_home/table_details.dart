import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewalletdemo/constant/bussiness.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TableDetailsPage extends StatefulWidget {
  final String table;

  const TableDetailsPage({super.key, required this.table});

  @override
  _TableDetailsPageState createState() => _TableDetailsPageState();
}

class _TableDetailsPageState extends State<TableDetailsPage> {
  final Map<String, int> _selectedItems = {};
  double _totalPrice = 0.0;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;

  Future<List<DocumentSnapshot>> _fetchProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('products')
        .get();
    return querySnapshot.docs;
  }

  void _addItem(String item, double price) {
    setState(() {
      if (_selectedItems.containsKey(item)) {
        _selectedItems[item] = _selectedItems[item]! + 1;
      } else {
        _selectedItems[item] = 1;
      }
      _totalPrice += price;
    });
    _updateTableTotalPrice();
  }

  void _removeItem(String item, double price) {
    setState(() {
      if (_selectedItems.containsKey(item) && _selectedItems[item]! > 0) {
        _selectedItems[item] = _selectedItems[item]! - 1;
        _totalPrice -= price;
      }
      if (_selectedItems[item] == 0) {
        _selectedItems.remove(item);
      }
    });
    _updateTableTotalPrice();
  }

  Future<void> _updateTableTotalPrice({bool resetTotal = false}) async {
    final tableRef =
        FirebaseFirestore.instance.collection('tables').doc(widget.table);
    await tableRef.update({
      'totalPrice': resetTotal ? 0.0 : _totalPrice,
    });

    if (resetTotal) {
      setState(() {
        _totalPrice = 0.0;
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _fetchTableTotalPrice() async {
    final tableRef =
        FirebaseFirestore.instance.collection('tables').doc(widget.table);
    final tableSnapshot = await tableRef.get();
    if (tableSnapshot.exists) {
      setState(() {
        _totalPrice = tableSnapshot['totalPrice'].toDouble();
      });
    }
  }

  Future<void> _verifyPhoneNumber() async {
    final String phoneNumber = _phoneController.text.trim();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolving case
        await _auth.signInWithCredential(credential);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Phone number automatically verified and user signed in')),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to verify phone number: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent.')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _codeController.text.trim(),
    );

    try {
      final User? user = (await _auth.signInWithCredential(credential)).user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully signed in UID: ${user.uid}')),
        );
        await _makePayment();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: $e')),
      );
    }
  }

  Future<void> _makePayment() async {
    final String phoneNumber = _phoneController.text.trim();

    // Kullanıcı belgesini telefon numarasına göre getir
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı bulunamadı!')),
      );
      return;
    }

    final userDoc = userSnapshot.docs.first;

    // Kullanıcının bakiyesini güncelle
    final double currentBalance = userDoc['balance'].toDouble();
    if (currentBalance < _totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye!')),
      );
      return;
    }

    // İşletme hesabının bakiyesini güncelle
    const businessUserId = 'wIynGHeYf...'; // İşletme kullanıcısının kimliği
    final businessUserRef =
        FirebaseFirestore.instance.collection('users').doc(businessUserId);
    final businessUserSnapshot = await businessUserRef.get();

    if (!businessUserSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşletme hesabı bulunamadı!')),
      );
      return;
    }

    final double businessCurrentBalance =
        businessUserSnapshot['balance'].toDouble();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userDoc.id)
        .update({
      'balance': currentBalance - _totalPrice,
    });

    await businessUserRef.update({
      'balance': businessCurrentBalance + _totalPrice,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ödeme başarılı!')),
    );

    // Ödeme sonrası masanın toplam fiyatını sıfırla
    await _updateTableTotalPrice(resetTotal: true);
  }

  @override
  void initState() {
    super.initState();
    _fetchTableTotalPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.table),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<DocumentSnapshot>>(
            future: _fetchProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Ürün bulunamadı.'));
              }
              final products = snapshot.data!;
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final itemName = product['name'];
                      final itemPrice = product['price'] is int
                          ? product['price'].toDouble()
                          : product['price'];
                      return ListTile(
                        title: Text(itemName),
                        subtitle: Text('$itemPrice TL'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _removeItem(itemName, itemPrice),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _addItem(itemName, itemPrice),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Text(
                    'Toplam Fiyat: $_totalPrice TL',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  QrImageView(
                    data:
                        '${CBussiness.bussinessUid}:$_totalPrice', // Sadece toplam fiyatı QR koduna dahil ediyoruz.
                    size: 200,
                  ),
                  ElevatedButton(
                    onPressed: () => _updateTableTotalPrice(),
                    child: const Text('Toplam Fiyatı Güncelle'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon Numarası',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _verifyPhoneNumber,
                    child: const Text('Telefon Numarasını Doğrula'),
                  ),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Doğrulama Kodu',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _signInWithPhoneNumber,
                    child: const Text('Ödeme Yap'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _updateTableTotalPrice(resetTotal: true),
                    child: const Text('Toplam Fiyatı Sıfırla'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
