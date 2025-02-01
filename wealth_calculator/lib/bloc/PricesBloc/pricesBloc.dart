import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/utils/price_utils.dart';

class PricesBloc extends Bloc<PricesEvent, PricesState> {
  final PriceFetcher _priceFetcher = PriceFetcher();

  PricesBloc() : super(PricesLoading()) {
    on<LoadPrices>(_onLoadPrices);
    on<SearchPrices>(_onSearchPrices);
  }

  // This method fetches the prices from the websites, and then divides them into their relevant categories
  Future<void> _onLoadPrices(
      LoadPrices event, Emitter<PricesState> emit) async {
    emit(PricesLoading());

    try {
      final allPrices = await _priceFetcher.fetchPrices();
      print(allPrices);
      emit(PricesLoaded(
        commodityPrices: allPrices[3],
        goldPrices: allPrices[0],
        currencyPrices: allPrices[1],
        equityPrices: allPrices[2],
      ));
    } catch (e) {
      print('Error occurred: $e');
      emit(PricesError('Failed to load prices.'));
    }
  }

  // Bu metod, yüklü fiyatlar arasında arama yapar
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
