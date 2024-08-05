import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wealth_calculator/views/PriceViews.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    Duration duration = Duration(seconds: 3);
    return Timer(duration, goHome);
  }

  void goHome() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return PricesScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("images/logo.json"),
                Lottie.asset("images/isim.json")
              ],
            )),
      ),
    );
  }
}
