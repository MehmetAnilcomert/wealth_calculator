import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/utils/price_utils.dart';

class PricesBloc extends Bloc<PricesEvent, PricesState> {
  final PriceFetcher _priceFetcher =
      PriceFetcher(); // PriceFetcher'ı kullanacağız

  PricesBloc() : super(PricesLoading()) {
    on<LoadPrices>(_onLoadPrices);
    on<SearchPrices>(_onSearchPrices);
  }

  // Bu metod, fiyatları internetten çekmeye çalışır, çekilemezse veritabanından alır.
  Future<void> _onLoadPrices(
      LoadPrices event, Emitter<PricesState> emit) async {
    emit(PricesLoading());

    try {
      final allPrices = await _priceFetcher.fetchPrices();

      // Fiyatları ilgili kategorilere ayır
      List<WealthPrice> goldPrices =
          allPrices.where((price) => price.type == PriceType.gold).toList();
      List<WealthPrice> currencyPrices =
          allPrices.where((price) => price.type == PriceType.currency).toList();
      List<WealthPrice> equityPrices =
          allPrices.where((price) => price.type == PriceType.equity).toList();
      List<WealthPrice> commodityPrices = allPrices
          .where((price) => price.type == PriceType.commodity)
          .toList();

      emit(PricesLoaded(
        commodityPrices: commodityPrices,
        goldPrices: goldPrices,
        currencyPrices: currencyPrices,
        equityPrices: equityPrices,
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
