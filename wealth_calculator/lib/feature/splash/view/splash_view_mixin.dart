part of 'splash_view.dart';

mixin SplashViewMixin on State<SplashView> {
  void initializeLoading() {
    context.read<SplashCubit>().startLoading();
    context.read<PricesBloc>().add(LoadPrices());
  }

  void handleSplashComplete() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PricesView()),
    );
  }

  void listenToSplashState(BuildContext context, SplashState state) {
    if (state is SplashComplete) {
      handleSplashComplete();
    }
  }

  void listenToPricesState(BuildContext context, PricesState state) {
    if (state is PricesLoaded) {
      context.read<SplashCubit>().onDataLoaded();
      // Load inventory data in background for daily logging
      context.read<InventoryBloc>().add(const LoadInventoryData());
    }
  }
}
