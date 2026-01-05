import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

abstract class TempInventoryState extends Equatable {
  const TempInventoryState();

  @override
  List<Object> get props => [];
}

class InventoryInitial extends TempInventoryState {}

class InventoryLoading extends TempInventoryState {}

class InventoryLoaded extends TempInventoryState {
  final List<SavedWealths> savedWealths;
  final List<WealthPrice> goldPrices;
  final List<WealthPrice> currencyPrices;
  final double totalPrice;
  final List<double> segments;
  final List<Color> colors;

  const InventoryLoaded({
    required this.savedWealths,
    required this.goldPrices,
    required this.currencyPrices,
    required this.totalPrice,
    required this.segments,
    required this.colors,
  });

  @override
  List<Object> get props => [
        savedWealths,
        goldPrices,
        currencyPrices,
        totalPrice,
        segments,
        colors,
      ];
}

class InventoryError extends TempInventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object> get props => [message];
}

class PricesLoaded extends TempInventoryState {}
