import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryState.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/services/DataScraping.dart';
import 'package:wealth_calculator/services/Wealthsdao.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  List<WealthPrice> _cachedGoldPrices = [];
  List<WealthPrice> _cachedCurrencyPrices = [];
  List<SavedWealths> _savedWealths = [];

  InventoryBloc() : super(InventoryInitial()) {
    on<LoadInventoryData>(_onLoadInventoryData);
    on<AddOrUpdateWealth>(_onEditWealth);
    on<DeleteWealth>(_onDeleteWealth);
  }

  Future<void> _onLoadInventoryData(
      LoadInventoryData event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());

    try {
      final wealthsDao = SavedWealthsdao();
      _savedWealths = await wealthsDao.getAllWealths();

      if (_cachedGoldPrices.isEmpty || _cachedCurrencyPrices.isEmpty) {
        _cachedGoldPrices = await fetchGoldPrices();
        _cachedCurrencyPrices = await fetchCurrencyPrices();
      }

      emit(_createLoadedState());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onEditWealth(
      AddOrUpdateWealth event, Emitter<InventoryState> emit) async {
    try {
      final wealthsDao = SavedWealthsdao();

      final newWealth = SavedWealths(
        id: event.wealth.id,
        type: event.wealth.type,
        amount: event.amount,
      );

      await wealthsDao.insertWealth(newWealth);

      _savedWealths = await wealthsDao.getAllWealths();

      emit(_createLoadedState());
    } catch (e) {
      emit(InventoryError('Failed to edit wealth.'));
    }
  }

  Future<void> _onDeleteWealth(
      DeleteWealth event, Emitter<InventoryState> emit) async {
    try {
      final wealthsDao = SavedWealthsdao();
      await wealthsDao.deleteWealth(event.id);

      // Update the cached _savedWealths list
      _savedWealths = await wealthsDao.getAllWealths();

      // Emit new state with updated data
      emit(_createLoadedState());
    } catch (e) {
      emit(InventoryError('Failed to delete wealth.'));
    }
  }

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
