import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'table_details.dart';
import 'table_management_screen.dart';

class BusinessHomeLayout extends StatefulWidget {
  const BusinessHomeLayout({super.key});

  @override
  State<BusinessHomeLayout> createState() => _BusinessHomeLayoutState();
}

class _BusinessHomeLayoutState extends State<BusinessHomeLayout> {
  List<DocumentSnapshot> _tables = [];

  @override
  void initState() {
    super.initState();
    _createTablesInFirestore().then((_) {
      _fetchTables();
    });
  }

  Future<void> _createTablesInFirestore() async {
    final tables = ['Masa 1', 'Masa 2', 'Masa 3', 'Masa 4', 'Masa 5', 'Masa 6'];
    final tablesCollection = FirebaseFirestore.instance.collection('tables');

    for (String table in tables) {
      final tableDoc = tablesCollection.doc(table);
      final tableSnapshot = await tableDoc.get();

      if (!tableSnapshot.exists) {
        await tableDoc.set({
          'name': table,
          'totalPrice': 0.0,
        });
      }
    }
  }

  Future<void> _fetchTables() async {
    final tablesCollection = FirebaseFirestore.instance.collection('tables');
    final querySnapshot = await tablesCollection.get();

    setState(() {
      _tables = querySnapshot.docs;
    });
  }

  void _navigateToTableDetails(String table) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableDetailsPage(table: table),
      ),
    );
  }

  void _navigateToTableManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TableManagementScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            onPressed: _navigateToTableManagement,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _tables.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  final table = _tables[index];
                  return InkWell(
                    onTap: () => _navigateToTableDetails(table['name']),
                    child: Card(
                      child: Center(
                        child: Text(
                          table['name'],
                          style: const TextStyle(fontSize: 24.0),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
