// prices_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/services/DataScraping.dart';

class GoldPricesBloc extends Bloc<GoldPricesEvent, GoldPricesState> {
  GoldPricesBloc() : super(GoldPricesLoading()) {
    on<LoadGoldPrices>(_onLoadGoldPrices);
  }

  Future<void> _onLoadGoldPrices(
      LoadGoldPrices event, Emitter<GoldPricesState> emit) async {
    try {
      final goldPrices = await fetchGoldPrices();
      final currencyPrices = await fetchCurrencyPrices();
      emit(GoldPricesLoaded(
          goldPrices: goldPrices, currencyPrices: currencyPrices));
    } catch (e) {
      print('Error occurred: $e');
      emit(GoldPricesError('Failed to load prices.'));
    }
  }
}
