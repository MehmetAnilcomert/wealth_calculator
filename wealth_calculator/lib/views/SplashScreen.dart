import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:wealth_calculator/bloc/Bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/Bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/Bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/views/PriceViews.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  bool _loadingComplete = false;

  @override
  void initState() {
    super.initState();
    startTimer();
    _startLoadingData();
  }

  void startTimer() {
    Duration duration = Duration(seconds: 3); // Animasyon süresi
    _timer = Timer(duration, _checkLoadingState);
  }

  void _startLoadingData() {
    // PricesScreen için gerekli verilerin yüklenmesini başlatın
    context.read<GoldPricesBloc>().add(LoadGoldPrices());
  }

  void _checkLoadingState() {
    if (_loadingComplete) {
      _goHome();
    } else {
      // Eğer yükleme tamamlanmadıysa dinlemeye devam et
      _timer = Timer(Duration(milliseconds: 500), _checkLoadingState);
    }
  }

  void _goHome() {
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
    return BlocListener<GoldPricesBloc, GoldPricesState>(
      listener: (context, state) {
        if (state is GoldPricesLoaded) {
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
