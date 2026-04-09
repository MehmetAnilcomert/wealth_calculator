import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

abstract class CalculatorState extends Equatable {
  const CalculatorState();

  @override
  List<Object?> get props => [];
}

class CalculatorInitial extends CalculatorState {}

class CalculatorLoading extends CalculatorState {}

class CalculatorLoaded extends CalculatorState {
  final double totalPrice;
  final List<double> segments;
  final List<Color> colors;
  final List<WealthPrice> goldPrices;
  final List<WealthPrice> currencyPrices;
  final List<SavedWealths> savedWealths;
  
  // New fields for sync info
  final DateTime? lastUpdatedAt;
  final bool isFromCache;

  const CalculatorLoaded({
    required this.totalPrice,
    required this.segments,
    required this.colors,
    required this.goldPrices,
    required this.currencyPrices,
    required this.savedWealths,
    this.lastUpdatedAt,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [
        totalPrice,
        segments,
        colors,
        goldPrices,
        currencyPrices,
        savedWealths,
        lastUpdatedAt,
        isFromCache,
      ];
}

class CalculatorError extends CalculatorState {
  final String message;

  const CalculatorError(this.message);

  @override
  List<Object?> get props => [message];
}
