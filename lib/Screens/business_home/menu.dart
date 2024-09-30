import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User? _currentUser;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  Future<void> addProduct(String name, double price) async {
    if (_currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('products')
          .add({
        'name': name,
        'price': price,
      });
    }
  }

  Future<void> updateProduct(String productId, double newPrice) async {
    if (_currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('products')
          .doc(productId)
          .update({
        'price': newPrice,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menü Yönetimi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _productNameController,
              decoration: const InputDecoration(labelText: 'Ürün Adı'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _productPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ürün Fiyatı'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final String name = _productNameController.text;
              final double price = double.parse(_productPriceController.text);
              addProduct(name, price);
            },
            child: const Text('Ürün Ekle'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _currentUser != null
                  ? _firestore
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .collection('products')
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final String productId = product.id;
                    final String name = product['name'];
                    final double price = product['price'];

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Fiyat: $price TL'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _productPriceController.text = price.toString();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Fiyat Güncelle'),
                                content: TextField(
                                  controller: _productPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Yeni Fiyat'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      final double newPrice = double.parse(
                                          _productPriceController.text);
                                      updateProduct(productId, newPrice);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Güncelle'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
