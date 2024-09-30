import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewalletdemo/Screens/auth/forgot_password.dart';
import 'package:ewalletdemo/Screens/business_auth/business_register.dart';
import 'package:ewalletdemo/Screens/business_home/business_bottom.dart'; // Import the BusinessBottom
import 'package:ewalletdemo/constant/bussiness.dart';
import 'package:ewalletdemo/utils/utils.dart';
import 'package:ewalletdemo/widgets/widget_auth.dart';
import 'package:ewalletdemo/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusinessLogin extends StatefulWidget {
  const BusinessLogin({super.key});

  @override
  State<BusinessLogin> createState() => _BusinessLoginState();
}

class _BusinessLoginState extends State<BusinessLogin> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _inputEmail() {
    return TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(hintText: 'Email'),
      validator: (value) => uValidator(
        value: value,
        isRequared: true,
        isEmail: true,
      ),
    );
  }

  Widget _inputPassword() {
    return Stack(
      children: <Widget>[
        TextFormField(
          controller: _password,
          obscureText: _obscureText,
          decoration: const InputDecoration(hintText: 'Şifre'),
          validator: (value) =>
              uValidator(value: value, isRequared: true, minLength: 6),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              setState(() => _obscureText = !_obscureText);
            },
          ),
        )
      ],
    );
  }

  Widget _inputForgot() {
    return GestureDetector(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
          child: const Text('Şifrenizi mi unuttunuz?'),
        ),
      ),
      onTap: () {
        wPushTo(context, const ForgotPassword());
      },
    );
  }

  Widget _inputSumbit() {
    return wInputSumbit('Giriş', () {
      _loginSementara();
    });
  }

  Widget _googleSignIn() {
    return wGoogleSignIn(() {});
  }

  Widget _textRegister() {
    return wTextLink('Hesabınız yok mu?', 'Kayıt ol',
        () => wPushReplaceTo(context, const BusinessRegister()));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: _isLoading
          ? wAppLoading(context)
          : Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        wAuthTitle(
                            title: 'Giriş',
                            subtitle: 'Lütfen email ve şifrenizi girin?'),
                        _inputEmail(),
                        _inputPassword(),
                        _inputForgot(),
                        _inputSumbit(),
                        _textRegister(),
                      ]),
                ),
              ),
            ),
    );
  }

  void _loginSementara() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        CBussiness.bussinessUid = user.uid;
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists && userData['userType'] == 'business') {
          // İşletme kullanıcısı ise BusinessBottom'a yönlendir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BusinessBottom()),
          );
        } else {
          // Bireysel kullanıcı ise hata göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu kullanıcı işletme hesabı değil.')),
          );
          await FirebaseAuth.instance.signOut(); // Çıkış yap
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş başarısız: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
