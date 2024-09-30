import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ewalletdemo/Screens/auth/verif_email.dart';
import 'package:ewalletdemo/Screens/business_auth/business_login.dart';
import 'package:ewalletdemo/utils/utils.dart';
import 'package:ewalletdemo/widgets/widget_auth.dart';
import 'package:ewalletdemo/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BusinessRegister extends StatefulWidget {
  const BusinessRegister({super.key});

  @override
  State<BusinessRegister> createState() => _BusinessRegisterState();
}

class _BusinessRegisterState extends State<BusinessRegister> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordconf = TextEditingController();
  late List<String> businessTypes;
  late String selectedBusinessType;

  @override
  void initState() {
    super.initState();
    businessTypes = ['Restoran/Kafe', 'Market', 'Taksi Durağı'];
    selectedBusinessType = businessTypes[0];
  }

  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _inputBusinessName() {
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      controller: _name,
      decoration: const InputDecoration(
          hintText: 'İşletme İsmi', helperText: 'İşletme ismini girin'),
      validator: (value) =>
          uValidator(value: value, isRequared: true, minLength: 3),
    );
  }

  Widget _businessTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedBusinessType,
      onChanged: (value) {
        setState(() {
          selectedBusinessType = value!;
        });
      },
      items: businessTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      decoration: const InputDecoration(
        hintText: 'İşletme Tipi',
      ),
    );
  }

  Widget _inputEmail() {
    return TextFormField(
      controller: _email,
      decoration:
          const InputDecoration(hintText: 'Email', helperText: 'Email giriniz'),
      validator: (value) =>
          uValidator(value: value, isRequared: true, isEmail: true),
    );
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
      _registerSementara();
    });
  }

  Widget _googleSignIn() {
    return wGoogleSignIn(() {});
  }

  Widget _textLogin() {
    return wTextLink('Hesabınız var mı ?', 'Giriş yap', () {
      wPushReplaceTo(context, const BusinessLogin());
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
                      _inputBusinessName(),
                      _businessTypeDropdown(),
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

  void _registerSementara() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _name.text,
          'email': _email.text,
          'phone': _phone.text,
          'businessType': selectedBusinessType,
          'userType': 'business', // İşletme kullanıcı tipi olarak ekle
          'balance': 0.0, // İşletme için başlangıç bakiyesi
        });

        // Kayıt başarılı olduktan sonra kullanıcıyı email doğrulama sayfasına yönlendir
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            return const VerifEmail();
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarısız: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
