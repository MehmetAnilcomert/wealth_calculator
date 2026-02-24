import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_event.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_state.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/state/base/base_bloc.dart';
import 'package:wealth_calculator/product/utility/price_utils.dart';
import 'package:wealth_calculator/product/service/custom_list_dao.dart';

class PricesBloc extends BaseBloc<PricesEvent, PricesState> {
  final PriceFetcher _priceFetcher = PriceFetcher();
  final CustomListDao _customListDao = CustomListDao();

  PricesBloc() : super(PricesLoading()) {
    on<LoadPrices>(_onLoadPrices);
    on<AddCustomPrice>(_onAddCustomPrice);
    on<DeleteCustomPrice>(_onDeleteCustomPrice);
  }

  Future<void> _onLoadPrices(
      LoadPrices event, Emitter<PricesState> emit) async {
    emit(PricesLoading());
    try {
      final allPrices = await _priceFetcher.fetchPrices();
      final customPrices = await _customListDao.getSelectedWealthPrices();

      List<WealthPrice> gold = allPrices[0];
      List<WealthPrice> currency = allPrices[1];
      List<WealthPrice> equity = allPrices[2];
      List<WealthPrice> commodity = List<WealthPrice>.from(allPrices[3]);
      List<WealthPrice> customLists = List<WealthPrice>.from(customPrices);

      // --- Silver conversion logic ---
      // 1. Find USD rate
      final usdPrice = currency.firstWhere(
        (p) => p.title.toLowerCase().contains('dolar'),
        orElse: () => WealthPrice(
            title: '',
            buyingPrice: '1',
            sellingPrice: '1',
            change: '',
            time: '',
            type: PriceType.currency),
      );

      double usdRate = double.tryParse(
              usdPrice.sellingPrice.replaceAll('.', '').replaceAll(',', '.')) ??
          1.0;

      // 2. Convert Silver Ounce to Gram TL
      const double ounceToGram = 31.1034768;

      WealthPrice? silverInCommodity;
      int silverIdx =
          commodity.indexWhere((p) => p.title.toLowerCase().contains('gümüş'));

      if (silverIdx != -1) {
        final silver = commodity[silverIdx];
        double ouncePrice = double.tryParse(
                silver.currentPrice?.replaceAll('.', '').replaceAll(',', '.') ??
                    '') ??
            0.0;

        if (ouncePrice > 0) {
          double gramTL = (ouncePrice * usdRate) / ounceToGram;
          String gramTLStr = gramTL.toStringAsFixed(2).replaceAll('.', ',');

          silverInCommodity = WealthPrice(
            title: 'Gümüş (TL/GR)',
            buyingPrice: gramTLStr,
            sellingPrice: gramTLStr,
            currentPrice: gramTLStr,
            change: silver.change,
            time: silver.time,
            type: silver.type,
            changeAmount: silver.changeAmount,
          );
          commodity[silverIdx] = silverInCommodity;
        }
      }

      // 3. Update Silver in custom lists if present
      if (silverInCommodity != null) {
        for (int i = 0; i < customLists.length; i++) {
          if (customLists[i].title.toLowerCase().contains('gümüş')) {
            customLists[i] = silverInCommodity;
          }
        }
      }

      emit(PricesLoaded(
        commodityPrices: commodity,
        goldPrices: gold,
        currencyPrices: currency,
        equityPrices: equity,
        customPrices: customLists,
      ));
    } catch (e) {
      emit(PricesError('Failed to load prices.'));
    }
  }

  Future<void> _onAddCustomPrice(
      AddCustomPrice event, Emitter<PricesState> emit) async {
    if (state is PricesLoaded) {
      final currentState = state as PricesLoaded;
      List<WealthPrice> updatedCustomPrices =
          List<WealthPrice>.from(currentState.customPrices);
      // To keep track of duplicates.
      List<String> duplicates = [];

      for (var wealthPrice in event.wealthPrices) {
        if (!updatedCustomPrices.contains(wealthPrice)) {
          await _customListDao.insertWealthPrice(wealthPrice);
          updatedCustomPrices.add(wealthPrice);
        } else {
          // If the item is already in the list, add it to the duplicates list.
          duplicates.add(wealthPrice.title);
        }
      }

      // If there are duplicates, emit an error message.
      if (duplicates.isNotEmpty) {
        emit(CustomPriceDuplicateError(
            'Aşağıdaki öğeler zaten var: ${duplicates.join(', ')}.'));
      }
      // Otherwise, update the state with the new custom prices.
      emit(currentState.copyWith(customPrices: updatedCustomPrices));
    }
  }

  Future<void> _onDeleteCustomPrice(
      DeleteCustomPrice event, Emitter<PricesState> emit) async {
    if (state is PricesLoaded) {
      final currentState = state as PricesLoaded;

      await _customListDao.deleteWealthPrice(event.wealthPrice);

      final updatedCustomPrices =
          List<WealthPrice>.from(currentState.customPrices)
            ..remove(event.wealthPrice);

      emit(currentState.copyWith(customPrices: updatedCustomPrices));
    }
  }
}
