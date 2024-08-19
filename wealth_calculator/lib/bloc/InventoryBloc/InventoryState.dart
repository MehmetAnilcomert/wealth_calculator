import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/modals/Wealths.dart';

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

  InventoryLoaded({
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

class InventoryError extends InventoryState {
  final String message;

  InventoryError(this.message);

  @override
  List<Object> get props => [message];
}
