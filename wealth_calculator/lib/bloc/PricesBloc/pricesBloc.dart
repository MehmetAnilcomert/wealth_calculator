import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/services/DataScraping.dart';

class PricesBloc extends Bloc<PricesEvent, PricesState> {
  PricesBloc() : super(PricesLoading()) {
    on<LoadPrices>(_onLoadPrices);
    on<SearchPrices>(_onSearchPrices);
  }

  Future<void> _onLoadPrices(
      LoadPrices event, Emitter<PricesState> emit) async {
    try {
      final goldPrices = await fetchGoldPrices();
      final currencyPrices = await fetchCurrencyPrices();
      final equityPrices = await fetchEquityData();
      fetchCommodityPrices();
      emit(PricesLoaded(
          goldPrices: goldPrices,
          currencyPrices: currencyPrices,
          equityPrices: equityPrices));
    } catch (e) {
      print('Error occurred: $e');
      emit(PricesError('Failed to load prices.'));
    }
  }

  void _onSearchPrices(SearchPrices event, Emitter<PricesState> emit) {
    if (state is PricesLoaded) {
      final currentState = state as PricesLoaded;

      // Arama mantığı
      final filteredPrices = currentState.goldPrices.where((price) {
        return price.title.toLowerCase().contains(event.query.toLowerCase());
      }).toList();

      // Sonuçları emit etme
      emit(PricesSearchResult(filteredPrices));
    }
  }
}
