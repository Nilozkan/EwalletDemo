import 'dart:async';

import 'package:ewalletdemo/Screens/accounts_layout.dart';
import 'package:ewalletdemo/Screens/home/home_layout.dart';
import 'package:ewalletdemo/widgets/widgets.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    _checkUserSementara(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: wAppLoading(context));
  }

  void _checkUserSementara(bool user) async {
    await Future.delayed(const Duration(seconds: 2));
    wPushReplaceTo(context, user ? const HomeLayout() : const AccountsLayout());
  }
}
