import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/Bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/Bloc/InventoryBloc/InventoryState.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/services/DataScraping.dart';
import 'package:wealth_calculator/services/Wealthsdao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(InventoryInitial()) {
    on<LoadInventoryData>(_onLoadInventoryData);
    on<AddOrUpdateWealth>(_onEditWealth);
    on<DeleteWealth>(_onDeleteWealth);
  }

  Future<void> _onLoadInventoryData(
      LoadInventoryData event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      final results = await Future.wait([
        SavedWealthsdao().getAllWealths(),
        fetchGoldPrices(),
        fetchCurrencyPrices(),
      ]);

      final savedWealths = results[0] as List<SavedWealths>;
      final goldPrices = results[1] as List<WealthPrice>;
      final currencyPrices = results[2] as List<WealthPrice>;

      final totalPrice =
          _calculateTotalPrice(savedWealths, goldPrices, currencyPrices);
      final segments =
          _calculateSegments(savedWealths, goldPrices, currencyPrices);
      final colors = _calculateColors(savedWealths, goldPrices, currencyPrices);

      emit(InventoryLoaded(
        savedWealths: savedWealths,
        goldPrices: goldPrices,
        currencyPrices: currencyPrices,
        totalPrice: totalPrice,
        segments: segments,
        colors: colors,
      ));
    } catch (e) {
      emit(InventoryError('Failed to load inventory data.'));
    }
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
      'Euro': Colors.blue,
      'İngiliz Sterlini': Colors.purple,
      'TL': Colors.red,
    };

    return [
      for (var wealth in savedWealths) colorMap[wealth.type] ?? Colors.grey
    ];
  }

  Future<void> _onEditWealth(
      AddOrUpdateWealth event, Emitter<InventoryState> emit) async {
    try {
      final wealthsDao = SavedWealthsdao();
      final existingWealth =
          await wealthsDao.getWealthByType(event.wealth.type);

      if (existingWealth != null) {
        // Update existing wealth
        final updatedWealth = SavedWealths(
          id: existingWealth.id,
          type: event.wealth.type,
          amount: event.amount,
        );
        await wealthsDao.updateWealth(updatedWealth);
        add(LoadInventoryData()); // Reload inventory data
      } else {
        // Insert new wealth
        final newWealth = SavedWealths(
          id: DateTime.now().millisecondsSinceEpoch,
          type: event.wealth.type,
          amount: event.amount,
        );
        await wealthsDao.insertWealth(newWealth);
        add(LoadInventoryData()); // Reload inventory data
      }
    } catch (e) {
      emit(InventoryError('Failed to edit wealth.'));
    }
  }

  Future<void> _onDeleteWealth(
      DeleteWealth event, Emitter<InventoryState> emit) async {
    try {
      final wealthsDao = SavedWealthsdao();
      await wealthsDao.deleteWealth(event.id);
      add(LoadInventoryData()); // Reload inventory data
    } catch (e) {
      emit(InventoryError('Failed to delete wealth.'));
    }
  }
}
