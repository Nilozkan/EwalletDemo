import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  _TableManagementScreenState createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  final TextEditingController _tableNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _tableId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masaları Yönet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tableNameController,
              decoration: const InputDecoration(labelText: 'Masa Adı'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createTable,
              child: const Text('Masa Oluştur'),
            ),
            const SizedBox(height: 20),
            if (_tableId != null)
              QrImageView(
                data: _tableId!,
                version: QrVersions.auto,
                size: 200.0,
              ),
          ],
        ),
      ),
    );
  }

  void _createTable() async {
    final tableName = _tableNameController.text;
    if (tableName.isNotEmpty) {
      final randomId = _generateRandomId();
      await _firestore.collection('tables').doc(randomId).set({
        'name': tableName,
        'totalPrice': 0.0,
      });
      setState(() {
        _tableId = randomId;
      });
    }
  }

  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
