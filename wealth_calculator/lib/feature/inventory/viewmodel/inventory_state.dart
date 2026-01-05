import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealth_history_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

abstract class InventoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<SavedWealths> savedWealths;
  final List<WealthPrice> goldPrices;
  final List<WealthPrice> currencyPrices;
  final double totalPrice;
  final List<double> segments;
  final List<Color> colors;
  final List<WealthHistory> pricesHistory;

  InventoryLoaded({
    required this.savedWealths,
    required this.goldPrices,
    required this.currencyPrices,
    required this.totalPrice,
    required this.segments,
    required this.colors,
    required this.pricesHistory,
  });

  @override
  List<Object> get props => [
        savedWealths,
        goldPrices,
        currencyPrices,
        totalPrice,
        segments,
        colors,
        pricesHistory,
      ];
}

class InventoryError extends InventoryState {
  final String message;

  InventoryError(this.message);

  @override
  List<Object> get props => [message];
}
