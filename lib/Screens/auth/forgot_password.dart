import 'package:ewalletdemo/utils/utils.dart';
import 'package:ewalletdemo/widgets/widget_auth.dart';
import 'package:ewalletdemo/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSent = false;

  Widget _inputEmail() {
    return Container(
      child: TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'Email',
          helperText: 'Emailinizi girin',
        ),
        validator: (value) =>
            uValidator(value: value, isRequared: true, isEmail: true),
      ),
    );
  }

  Widget _inputSumbit() {
    return wInputSumbit('Gönder', () {
      _forgotPasswordSementara();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: _isLoading
          ? wAppLoading(context)
          : Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black),
              ),
              resizeToAvoidBottomInset: false,
              body: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 30),
                      wAuthTitle(
                        title: 'Şifrenizi mi unuttunuz?',
                        subtitle: 'Emailinizi girin ve size link gönderelim.',
                      ),
                      _inputEmail(),
                      const SizedBox(height: 30),
                      _inputSumbit(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _forgotPasswordSementara() async {
    if (!_formKey.currentState!.validate()) return;

    if (_email.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      print('gönder');
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
        _isSent = true; // burada hata var daha sonra kontrol et
      });
      wShowToast(
          'Email gönderildi! Lütfen şifrenizi sıfırlamak için mailinizi kontrol ediniz.',
          context);
      Navigator.pop(context);
    } else {
      print('Email alanı boş olamaz.');
    }
  }
}
