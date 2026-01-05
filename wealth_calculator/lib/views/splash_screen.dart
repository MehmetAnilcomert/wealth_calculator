import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/views/prices_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  bool _loadingComplete = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    startTimer();
    _startLoadingData();
  }

  void startTimer() {
    Duration duration = const Duration(seconds: 3);
    _timer = Timer(duration, _checkLoadingState);
  }

  void _startLoadingData() {
    context.read<PricesBloc>().add(LoadPrices());
  }

  void _checkLoadingState() {
    Duration elapsed = DateTime.now().difference(_startTime);

    if (_loadingComplete || elapsed.inSeconds >= 7) {
      _goHome();
    } else {
      _timer = Timer(const Duration(milliseconds: 500), _checkLoadingState);
    }
  }

  void _goHome() {
    context.read<InventoryBloc>().add(LoadInventoryData());
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return PricesScreen();
    }));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PricesBloc, PricesState>(
      listener: (context, state) {
        if (state is PricesLoaded) {
          _loadingComplete = true;
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
