import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashDataLoaded extends SplashState {
  const SplashDataLoaded();
}

class SplashComplete extends SplashState {
  const SplashComplete();
}

class SplashTimeout extends SplashState {
  const SplashTimeout();
}
