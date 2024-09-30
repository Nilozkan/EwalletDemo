import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewalletdemo/Screens/auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:ewalletdemo/Screens/auth/forgot_password.dart';
import 'package:ewalletdemo/Screens/auth/register.dart';
import 'package:ewalletdemo/Screens/home/home_layout.dart';
import 'package:ewalletdemo/utils/utils.dart';
import 'package:ewalletdemo/widgets/widget_auth.dart';
import 'package:ewalletdemo/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService =
      AuthService(); // AuthService örneği oluşturun

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _inputEmail() {
    return Container(
        child: TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(hintText: 'Email'),
      validator: (value) => uValidator(
        value: value,
        isRequared: true,
        isEmail: true,
      ),
    ));
  }

  Widget _inputPassword() {
    return Stack(
      children: <Widget>[
        Container(
          child: TextFormField(
            controller: _password,
            obscureText: _obscureText,
            decoration: const InputDecoration(hintText: 'Şifre'),
            validator: (value) =>
                uValidator(value: value, isRequared: true, minLength: 6),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              !_obscureText ? Icons.visibility_off : Icons.visibility,
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
        () => wPushReplaceTo(context, const register()));
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
      User? user = await _authService.signInWithEmailAndPassword(
        _email.text,
        _password.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists && userData['userType'] == 'individual') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeLayout()),
          );
        } else {
          // userType individual değilse hata göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu kullanıcı bireysel hesap değil.')),
          );
          await _authService.signOut(); // Çıkış yap
        }
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş sırasında bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
