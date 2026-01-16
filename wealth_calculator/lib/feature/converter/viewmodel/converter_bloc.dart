import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/converter/model/conversion_result_model.dart';
import 'package:wealth_calculator/feature/converter/viewmodel/converter_event.dart';
import 'package:wealth_calculator/feature/converter/viewmodel/converter_state.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/service/data_scraping.dart';
import 'package:wealth_calculator/product/state/base/base_bloc.dart';

/// BLoC for handling TL to wealth conversion logic
class ConverterBloc extends BaseBloc<ConverterEvent, ConverterState> {
  List<WealthPrice> _cachedGoldPrices = [];
  List<WealthPrice> _cachedCurrencyPrices = [];

  /// Items to exclude from converter calculations
  static const List<String> _hiddenItems = [
    'Altın (ONS/\$)',
    'Altın (\$/kg)',
    'Altın (Euro/kg)',
    'Külçe Altın (\$)',
  ];

  ConverterBloc() : super(ConverterInitial()) {
    on<LoadConverterData>(_onLoadConverterData);
    on<ConvertTLAmount>(_onConvertTLAmount);
    on<ChangePriceTypeFilter>(_onChangePriceTypeFilter);
    on<ClearConversion>(_onClearConversion);
  }

  /// Load initial price data
  Future<void> _onLoadConverterData(
    LoadConverterData event,
    Emitter<ConverterState> emit,
  ) async {
    emit(ConverterLoading());

    try {
      if (_cachedGoldPrices.isEmpty || _cachedCurrencyPrices.isEmpty) {
        _cachedGoldPrices = await fetchGoldPrices();
        _cachedCurrencyPrices = await fetchCurrencyPrices();
      }

      emit(ConverterLoaded(
        goldPrices: _cachedGoldPrices,
        currencyPrices: _cachedCurrencyPrices,
        conversionResults: [],
        tlAmount: 0.0,
        selectedType: PriceType.gold,
      ));
    } catch (e) {
      emit(ConverterError('Failed to load price data: ${e.toString()}'));
    }
  }

  /// Convert TL amount to wealth amounts
  Future<void> _onConvertTLAmount(
    ConvertTLAmount event,
    Emitter<ConverterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ConverterLoaded) return;

    try {
      final List<WealthPrice> selectedPrices =
          event.filterType == PriceType.gold
              ? _cachedGoldPrices
              : _cachedCurrencyPrices;

      final conversionResults = _calculateConversions(
        event.tlAmount,
        selectedPrices,
      );

      emit(currentState.copyWith(
        conversionResults: conversionResults,
        tlAmount: event.tlAmount,
        selectedType: event.filterType,
      ));
    } catch (e) {
      emit(ConverterError('Failed to convert: ${e.toString()}'));
    }
  }

  /// Change price type filter
  Future<void> _onChangePriceTypeFilter(
    ChangePriceTypeFilter event,
    Emitter<ConverterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ConverterLoaded) return;

    try {
      final List<WealthPrice> selectedPrices = event.type == PriceType.gold
          ? _cachedGoldPrices
          : _cachedCurrencyPrices;

      final conversionResults = currentState.tlAmount > 0
          ? _calculateConversions(currentState.tlAmount, selectedPrices)
          : <ConversionResult>[];

      emit(currentState.copyWith(
        conversionResults: conversionResults,
        selectedType: event.type,
      ));
    } catch (e) {
      emit(ConverterError('Failed to change filter: ${e.toString()}'));
    }
  }

  /// Clear conversion results
  Future<void> _onClearConversion(
    ClearConversion event,
    Emitter<ConverterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ConverterLoaded) return;

    emit(currentState.copyWith(
      conversionResults: [],
      tlAmount: 0.0,
    ));
  }

  /// Calculate conversions for all items in the selected price list
  List<ConversionResult> _calculateConversions(
    double tlAmount,
    List<WealthPrice> prices,
  ) {
    return prices
        .where((price) => !_hiddenItems.contains(price.title)) // Filter out hidden items
        .map((price) => ConversionResult.fromTLAmount(price, tlAmount))
        .where((result) => result.amount > 0) // Filter out invalid results
        .toList()
      ..sort(
          (a, b) => b.amount.compareTo(a.amount)); // Sort by amount descending
  }
}
