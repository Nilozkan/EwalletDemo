import 'package:ewalletdemo/Screens/auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:ewalletdemo/Screens/auth/login.dart';
import 'package:ewalletdemo/Screens/auth/verif_email.dart';
import 'package:ewalletdemo/utils/utils.dart';
import 'package:ewalletdemo/widgets/widget_auth.dart';
import 'package:ewalletdemo/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordconf = TextEditingController();

  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService =
      AuthService(); // AuthService örneği oluşturun

  Widget _inputName() {
    return Container(
        child: TextFormField(
      textCapitalization: TextCapitalization.words,
      controller: _name,
      decoration: const InputDecoration(
          hintText: 'İsim', helperText: 'Full isminizi girin'),
      validator: (value) =>
          uValidator(value: value, isRequared: true, minLength: 3),
    ));
  }

  Widget _inputEmail() {
    return Container(
        child: TextFormField(
      controller: _email,
      decoration:
          const InputDecoration(hintText: 'Email', helperText: 'Email giriniz'),
      validator: (value) =>
          uValidator(value: value, isRequared: true, isEmail: true),
    ));
  }

  Widget _inputPhoneNumber() {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly // Sadece rakam girişi sağlar
      ],
      controller: _phone,
      decoration: const InputDecoration(
          hintText: 'Telefon Numarası', helperText: 'Telefon Numarası giriniz'),
      validator: (value) =>
          uValidator(value: value, isRequared: true, isEmail: false),
    );
  }

  Widget _inputPassword() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _password,
            decoration:
                const InputDecoration(hintText: '*****', helperText: 'Şifre'),
            validator: (value) => uValidator(
                value: value,
                isRequared: true,
                minLength: 6), //artık register da çalşmıyo
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: TextFormField(
            controller: _passwordconf,
            decoration: const InputDecoration(
                hintText: '*****', helperText: 'Şifrenizi onaylayın'),
            validator: (value) => uValidator(
                value: value,
                isRequared: true,
                minLength: 6,
                match: _password.text),
          ),
        ),
      ],
    );
  }

  Widget _inputSumbit() {
    return wInputSumbit('Kayıt ol', () {
      _registerUser();
    });
  }

  Widget _googleSignIn() {
    return wGoogleSignIn(() {});
  }

  Widget _textLogin() {
    return wTextLink('Hesabınız var mı ?', 'Giriş yap', () {
      wPushReplaceTo(context, const Login());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: _isLoading
          ? wAppLoading(context)
          : Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      const SizedBox(height: 30),
                      wAuthTitle(
                          title: 'Kayıt ol',
                          subtitle: 'Kayıt olmak için formu doldurun'),
                      _inputName(),
                      _inputEmail(),
                      _inputPhoneNumber(),
                      _inputPassword(),
                      const SizedBox(height: 30),
                      _inputSumbit(),
                      _textLogin(),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    User? user = await _authService.registerWithEmailAndPassword(
      _name.text,
      _email.text,
      _phone.text,
      _password.text,
      'individual', // Bireysel kullanıcı türü
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return const VerifEmail();
        },
      );
    }
  }
}
