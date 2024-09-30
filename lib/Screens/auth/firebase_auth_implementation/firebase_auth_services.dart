import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmailAndPassword(String name, String email,
      String phone, String password, String userType) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'userType': userType,
          'balance': 0,
        });
      }

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

Future<void> _createTablesInFirestore() async {
  final tables = ['Masa 1', 'Masa 2', 'Masa 3', 'Masa 4', 'Masa 5', 'Masa 6'];
  final tablesCollection = FirebaseFirestore.instance.collection('tables');

  for (String table in tables) {
    final tableDoc = tablesCollection.doc(table);
    final tableSnapshot = await tableDoc.get();

    // Eğer masa zaten Firestore'da yoksa oluştur
    if (!tableSnapshot.exists) {
      await tableDoc.set({
        'name': table,
        'totalPrice': 0.0,
      });
    }
  }
}
