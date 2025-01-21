// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:payroll/utils/container.dart';
import 'package:payroll/utils/mediaquery.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutsideContainer(
      height: double.infinity,
      width: double.infinity,
      child: Center(
          child: Image.asset(
        "assets/images/logo.png",
        width: Sizes.width * .7,
        height: Sizes.height * .35,
      )),
    );
  }
}
