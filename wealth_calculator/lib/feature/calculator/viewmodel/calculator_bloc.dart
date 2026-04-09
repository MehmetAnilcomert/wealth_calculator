import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_event.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_state.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/service/price_repository.dart';
import 'package:wealth_calculator/product/state/base/base_bloc.dart';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

/// BLoC for handling total wealth calculation logic
class CalculatorBloc extends BaseBloc<CalculatorEvent, CalculatorState> {
  final PriceRepository _priceRepository;
  
  // Internal cache of user's saved wealths for this session
  List<SavedWealths> _savedWealths = [];

  CalculatorBloc({
    required PriceRepository priceRepository,
  })  : _priceRepository = priceRepository,
        super(CalculatorInitial()) {
    on<LoadCalculatorData>(_onLoadCalculatorData);
    on<AddOrUpdateCalculatorWealth>(_onAddOrUpdateCalculatorWealth);
    on<DeleteCalculatorWealth>(_onDeleteCalculatorWealth);
  }

  Future<void> _onLoadCalculatorData(
    LoadCalculatorData event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(CalculatorLoading());

    try {
      final goldPrices = _priceRepository.goldPrices;
      final currencyPrices = _priceRepository.currencyPrices;

      if (goldPrices.isEmpty && currencyPrices.isEmpty) {
        await _priceRepository.refresh();
      }

      _calculateAndEmit(emit);
    } catch (e) {
      emit(CalculatorError(LocaleKeys.failedToLoadCalculatorData.tr(namedArgs: {'error': e.toString()})));
    }
  }

  void _onAddOrUpdateCalculatorWealth(
    AddOrUpdateCalculatorWealth event,
    Emitter<CalculatorState> emit,
  ) {
    String type = '';
    if (event.wealth is SavedWealths) {
      type = (event.wealth as SavedWealths).type;
    } else if (event.wealth is WealthPrice) {
      type = (event.wealth as WealthPrice).title;
    }

    final index = _savedWealths.indexWhere((w) => w.type == type);

    if (index != -1) {
      _savedWealths[index] = _savedWealths[index].copyWith(amount: event.amount);
    } else {
      _savedWealths.add(SavedWealths(
        id: DateTime.now().millisecondsSinceEpoch,
        type: type,
        amount: event.amount,
      ));
    }

    _calculateAndEmit(emit);
  }

  void _onDeleteCalculatorWealth(
    DeleteCalculatorWealth event,
    Emitter<CalculatorState> emit,
  ) {
    _savedWealths.removeWhere((w) => w.id == event.id);
    _calculateAndEmit(emit);
  }

  void _calculateAndEmit(Emitter<CalculatorState> emit) {
    final goldPrices = _priceRepository.goldPrices;
    final currencyPrices = _priceRepository.currencyPrices;

    double total = 0.0;
    List<double> segments = [];
    List<Color> colors = [];

    final List<Color> chartColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFF4CAF50), // Green for Currency
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF5722), // Orange
    ];

    int colorIdx = 0;

    for (var wealth in _savedWealths) {
      final priceInfo = _findPriceForWealth(wealth.type, goldPrices, currencyPrices);
      if (priceInfo != null) {
        String cleanPrice = priceInfo.buyingPrice.replaceAll('.', '').replaceAll(',', '.');
        double priceValue = double.tryParse(cleanPrice) ?? 0.0;
        
        double subTotal = wealth.amount * priceValue;
        total += subTotal;
        
        segments.add(subTotal);
        colors.add(chartColors[colorIdx % chartColors.length]);
        colorIdx++;
      }
    }

    emit(CalculatorLoaded(
      totalPrice: total,
      segments: segments,
      colors: colors,
      goldPrices: goldPrices,
      currencyPrices: currencyPrices,
      savedWealths: List.from(_savedWealths),
      lastUpdatedAt: _priceRepository.lastUpdatedAt,
      isFromCache: _priceRepository.isFromCache,
    ));
  }

  WealthPrice? _findPriceForWealth(
    String type,
    List<WealthPrice> gold,
    List<WealthPrice> currency,
  ) {
    try {
      return gold.firstWhere((p) => p.title == type);
    } catch (_) {
      try {
        return currency.firstWhere((p) => p.title == type);
      } catch (_) {
        return null;
      }
    }
  }
}
