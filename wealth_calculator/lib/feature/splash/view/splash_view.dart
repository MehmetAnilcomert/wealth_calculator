import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_bloc.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_event.dart';
import 'package:wealth_calculator/feature/prices/view/prices_view.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_event.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_state.dart';
import 'package:wealth_calculator/feature/splash/viewmodel/splash_cubit.dart';
import 'package:wealth_calculator/feature/splash/viewmodel/splash_state.dart';

part 'splash_view_mixin.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SplashViewMixin {
  @override
  void initState() {
    super.initState();
    initializeLoading();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SplashCubit, SplashState>(
          listener: listenToSplashState,
        ),
        BlocListener<PricesBloc, PricesState>(
          listener: listenToPricesState,
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("images/logo.json"),
                Lottie.asset("images/isim.json"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
