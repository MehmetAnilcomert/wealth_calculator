import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/services/DataScraping.dart';

class PricesBloc extends Bloc<PricesEvent, PricesState> {
  PricesBloc() : super(PricesLoading()) {
    on<LoadPrices>(_onLoadPrices);
    on<SearchPrices>(_onSearchPrices);
  }

  // This method is used to load the prices from the internet with the help of the DataScraping service
  Future<void> _onLoadPrices(
      LoadPrices event, Emitter<PricesState> emit) async {
    try {
      final goldPrices = await fetchGoldPrices();
      final currencyPrices = await fetchCurrencyPrices();
      final equityPrices = await fetchEquityData();
      final commodityPrices = await fetchCommodityPrices();
      emit(PricesLoaded(
          commodityPrices: commodityPrices,
          goldPrices: goldPrices,
          currencyPrices: currencyPrices,
          equityPrices: equityPrices));
    } catch (e) {
      print('Error occurred: $e');
      emit(PricesError('Failed to load prices.'));
    }
  }

  // This method is used to search the prices on the loaded prices in prices screen
  void _onSearchPrices(SearchPrices event, Emitter<PricesState> emit) {
    if (state is PricesLoaded) {
      final currentState = state as PricesLoaded;

      final filteredPrices = currentState.goldPrices.where((price) {
        return price.title.toLowerCase().contains(event.query.toLowerCase());
      }).toList();

      emit(PricesSearchResult(filteredPrices));
    }
  }
}
