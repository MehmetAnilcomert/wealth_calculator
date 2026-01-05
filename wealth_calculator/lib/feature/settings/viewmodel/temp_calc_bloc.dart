import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/settings/viewmodel/temp_calc_event.dart';
import 'package:wealth_calculator/feature/settings/viewmodel/temp_calc_state.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/product/service/DataScraping.dart';

class TempInventoryBloc extends Bloc<TempInventoryEvent, TempInventoryState> {
  // Temporary lists
  List<WealthPrice> _cachedGoldPrices = [];
  List<WealthPrice> _cachedCurrencyPrices = [];
  List<SavedWealths> _savedWealths = [];

  TempInventoryBloc() : super(InventoryInitial()) {
    on<LoadInventoryData>(_onLoadInventoryData);
    on<AddOrUpdateWealth>(_onEditWealth);
    on<DeleteWealth>(_onDeleteWealth);
  }

  Future<void> _onLoadInventoryData(
      LoadInventoryData event, Emitter<TempInventoryState> emit) async {
    emit(InventoryLoading());

    try {
      // Initialize temporary lists
      _savedWealths = [];

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
      AddOrUpdateWealth event, Emitter<TempInventoryState> emit) async {
    try {
      final existingWealthIndex = _savedWealths
          .indexWhere((wealth) => wealth.type == event.wealth.type);

      if (existingWealthIndex != -1) {
        // Update existing wealth
        _savedWealths[existingWealthIndex] = SavedWealths(
            id: _savedWealths[existingWealthIndex].id,
            type: event.wealth.type,
            amount: event.amount);
      } else {
        // Add new wealth
        final newWealth = SavedWealths(
          id: DateTime.now().millisecondsSinceEpoch,
          type: event.wealth.type,
          amount: event.amount,
        );
        _savedWealths.add(newWealth);
      }

      // Emit new state with updated data
      emit(_createLoadedState());
    } catch (e) {
      emit(InventoryError('Failed to edit wealth.'));
    }
  }

  Future<void> _onDeleteWealth(
      DeleteWealth event, Emitter<TempInventoryState> emit) async {
    try {
      _savedWealths.removeWhere((wealth) => wealth.id == event.id);
      emit(_createLoadedState());
    } catch (e) {
      emit(InventoryError('Failed to delete wealth.'));
    }
  }

  InventoryLoaded _createLoadedState() {
    return InventoryLoaded(
      totalPrice: _calculateTotalPrice(
          _savedWealths, _cachedGoldPrices, _cachedCurrencyPrices),
      segments: _calculateSegments(
          _savedWealths, _cachedGoldPrices, _cachedCurrencyPrices),
      colors: _calculateColors(
          _savedWealths, _cachedGoldPrices, _cachedCurrencyPrices),
      goldPrices: _cachedGoldPrices,
      currencyPrices: _cachedCurrencyPrices,
      savedWealths: _savedWealths,
    );
  }

  double _calculateTotalPrice(List<SavedWealths> savedWealths,
      List<WealthPrice> goldPrices, List<WealthPrice> currencyPrices) {
    double total = 0;
    for (var wealth in savedWealths) {
      double price = 0.0;
      for (var gold in goldPrices) {
        if (gold.title == wealth.type) {
          price = double.parse(gold.buyingPrice.replaceAll(',', '.').trim());
          break;
        }
      }
      if (price == 0.0) {
        for (var currency in currencyPrices) {
          if (currency.title == wealth.type) {
            price =
                double.parse(currency.buyingPrice.replaceAll(',', '.').trim());
            break;
          }
        }
      }
      total += price * wealth.amount;
    }
    return total;
  }

  List<double> _calculateSegments(List<SavedWealths> savedWealths,
      List<WealthPrice> goldPrices, List<WealthPrice> currencyPrices) {
    List<double> segments = [];
    double total = 0;
    for (var wealth in savedWealths) {
      double price = 0.0;
      for (var gold in goldPrices) {
        if (gold.title == wealth.type) {
          price = double.parse(gold.buyingPrice.replaceAll(',', '.').trim());
          break;
        }
      }
      if (price == 0.0) {
        for (var currency in currencyPrices) {
          if (currency.title == wealth.type) {
            price =
                double.parse(currency.buyingPrice.replaceAll(',', '.').trim());
            break;
          }
        }
      }
      double value = price * wealth.amount;
      total += value;
      segments.add(value);
    }

    if (total > 0) {
      segments = segments.map((segment) => (segment / total) * 360).toList();
    }
    return segments;
  }

  List<Color> _calculateColors(List<SavedWealths> savedWealths,
      List<WealthPrice> goldPrices, List<WealthPrice> currencyPrices) {
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

    return [
      for (var wealth in savedWealths) colorMap[wealth.type] ?? Colors.grey
    ];
  }
}
