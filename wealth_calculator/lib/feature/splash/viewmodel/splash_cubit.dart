import 'dart:async';
import 'package:wealth_calculator/feature/splash/viewmodel/splash_state.dart';
import 'package:wealth_calculator/product/product.dart';

class SplashCubit extends BaseCubit<SplashState> {
  SplashCubit() : super(const SplashInitial());

  Timer? _timeoutTimer;
  DateTime? _startTime;
  bool _dataLoaded = false;

  void startLoading() {
    _startTime = DateTime.now();
    emit(const SplashLoading());
    _startTimeoutChecker();
  }

  void _startTimeoutChecker() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 3), _checkLoadingState);
  }

  void _checkLoadingState() {
    if (_startTime == null) return;

    final elapsed = DateTime.now().difference(_startTime!);

    if (_dataLoaded || elapsed.inSeconds >= 7) {
      emit(const SplashComplete());
    } else {
      _timeoutTimer =
          Timer(const Duration(milliseconds: 500), _checkLoadingState);
    }
  }

  void onDataLoaded() {
    _dataLoaded = true;
    emit(const SplashDataLoaded());
  }

  @override
  Future<void> close() {
    _timeoutTimer?.cancel();
    return super.close();
  }
}
