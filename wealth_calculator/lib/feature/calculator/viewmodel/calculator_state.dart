import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

abstract class CalculatorState extends Equatable {
  const CalculatorState();

  @override
  List<Object> get props => [];
}

class CalculatorInitial extends CalculatorState {}

class CalculatorLoading extends CalculatorState {}

class CalculatorLoaded extends CalculatorState {
  final List<SavedWealths> savedWealths;
  final List<WealthPrice> goldPrices;
  final List<WealthPrice> currencyPrices;
  final double totalPrice;
  final List<double> segments;
  final List<Color> colors;

  const CalculatorLoaded({
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

class CalculatorError extends CalculatorState {
  final String message;

  const CalculatorError(this.message);

  @override
  List<Object> get props => [message];
}
