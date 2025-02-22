import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/utils/price_utils.dart';
import 'package:wealth_calculator/services/CustomListDao.dart';

class PricesBloc extends Bloc<PricesEvent, PricesState> {
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

      emit(PricesLoaded(
        commodityPrices: allPrices[3],
        goldPrices: allPrices[0],
        currencyPrices: allPrices[1],
        equityPrices: allPrices[2],
        customPrices: customPrices,
      ));
    } catch (e) {
      print('Error occurred: $e');
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
