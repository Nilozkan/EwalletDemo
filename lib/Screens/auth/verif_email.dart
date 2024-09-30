import 'package:flutter/material.dart';

class VerifEmail extends StatefulWidget {
  const VerifEmail({super.key});

  @override
  State<VerifEmail> createState() => _VerifEmailState();
}

class _VerifEmailState extends State<VerifEmail> {
  bool _isLoading = false;
  bool _isSent = false;

  Widget resendEmailButton() {
    return TextButton(
      onPressed: () async {
        setState(() {
          _isLoading = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isLoading = false;
          _isSent = true;
        });
      },
      child: Text(
        _isLoading ? 'Göderiliyor' : 'Tekrar gönder',
        style: const TextStyle(
          color: Colors.black, // Change the color as desired
        ),
      ),
    );
  }

  Widget resendEmailMsg() {
    return Container(
      child: const Text(
        'Email gönderildi!',
        style: TextStyle(color: Colors.green),
      ),
    );
  }

  Widget buildBottomWidget() {
    return _isSent ? resendEmailMsg() : resendEmailButton();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.2,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.drag_handle),
          ),
          const Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  'Kayıt başarılı',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
