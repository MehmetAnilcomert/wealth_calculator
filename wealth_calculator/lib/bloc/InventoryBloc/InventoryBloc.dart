import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryState.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/services/DataScraping.dart';
import 'package:wealth_calculator/services/Wealthsdao.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final SavedWealthsdao _wealthsDao =
      SavedWealthsdao(); // Burada tek bir instance oluşturduk

  List<WealthPrice> _cachedGoldPrices = [];
  List<WealthPrice> _cachedCurrencyPrices = [];
  List<SavedWealths> _savedWealths = [];

  InventoryBloc() : super(InventoryInitial()) {
    on<LoadInventoryData>(_onLoadInventoryData);
    on<AddOrUpdateWealth>(_onEditWealth);
    on<DeleteWealth>(_onDeleteWealth);
  }

  // This method is used to load the inventory data from the database
  Future<void> _onLoadInventoryData(
      LoadInventoryData event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());

    try {
      _savedWealths = await _wealthsDao.getAllWealths();
      _cachedGoldPrices = await fetchGoldPrices();
      _cachedCurrencyPrices = await fetchCurrencyPrices();

      emit(_createLoadedState());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  // This method is used to add or update a wealth in the inventory database
  Future<void> _onEditWealth(
      AddOrUpdateWealth event, Emitter<InventoryState> emit) async {
    try {
      final existingWealth =
          await _wealthsDao.getWealthByType(event.wealth.type);

      if (existingWealth != null) {
        final updatedWealth = SavedWealths(
          id: existingWealth.id,
          type: event.wealth.type,
          amount: event.amount,
        );
        await _wealthsDao.updateWealth(updatedWealth);
      } else {
        final newWealth = SavedWealths(
          id: DateTime.now().millisecondsSinceEpoch,
          type: event.wealth.type,
          amount: event.amount,
        );
        await _wealthsDao.insertWealth(newWealth);
      }

      _savedWealths = await _wealthsDao.getAllWealths();
      emit(_createLoadedState());
    } catch (e) {
      emit(InventoryError('Failed to edit wealth.'));
    }
  }

  // This method is used to delete a wealth from the inventory database
  Future<void> _onDeleteWealth(
      DeleteWealth event, Emitter<InventoryState> emit) async {
    try {
      await _wealthsDao.deleteWealth(event.id);
      _savedWealths = await _wealthsDao.getAllWealths();
      emit(_createLoadedState());
    } catch (e) {
      emit(InventoryError('Failed to delete wealth.'));
    }
  }

  // This method is used to create the loaded state.
  // Loaded state is used to display the inventory data.
  // Loaded state contains the total price, segments, colors and saved wealths` list.
  InventoryLoaded _createLoadedState() {
    double totalPrice = 0;
    List<double> segments = [];
    List<Color> colors = [];

    final colorMap = {
      'Altın (TL/GR)': Colors.yellow,
      'Cumhuriyet Altını': Colors.yellow,
      'Yarım Altın': Colors.yellow,
      'Çeyrek Altın': Colors.yellow,
      'ABD Doları': Colors.green,
      'Euro': Colors.blue[700],
      'İngiliz Sterlini': Colors.purple,
      'TL': Colors.red,
    };

    for (var wealth in _savedWealths) {
      double price =
          _findPrice(wealth.type, _cachedGoldPrices, _cachedCurrencyPrices);
      double value = price * wealth.amount;
      totalPrice += value;
      segments.add(value);
      colors.add(colorMap[wealth.type] ?? Colors.grey);
    }

    if (totalPrice > 0) {
      segments =
          segments.map((segment) => (segment / totalPrice) * 360).toList();
    }

    return InventoryLoaded(
      totalPrice: totalPrice,
      segments: segments,
      colors: colors,
      goldPrices: _cachedGoldPrices,
      currencyPrices: _cachedCurrencyPrices,
      savedWealths: _savedWealths,
    );
  }

  // This helper method is used to find the price of a wealth type.
  double _findPrice(String type, List<WealthPrice> goldPrices,
      List<WealthPrice> currencyPrices) {
    for (var gold in goldPrices) {
      if (gold.title == type) {
        return double.parse(gold.buyingPrice.replaceAll(',', '.').trim());
      }
    }
    for (var currency in currencyPrices) {
      if (currency.title == type) {
        return double.parse(currency.buyingPrice.replaceAll(',', '.').trim());
      }
    }
    return 0.0;
  }
}
