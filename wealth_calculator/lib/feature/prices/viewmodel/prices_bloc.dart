import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_event.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_state.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/state/base/base_bloc.dart';
import 'package:wealth_calculator/product/service/custom_list_dao.dart';
import 'package:wealth_calculator/product/service/price_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

class PricesBloc extends BaseBloc<PricesEvent, PricesState> {
  PricesBloc({
    required PriceRepository priceRepository,
  })  : _priceRepository = priceRepository,
        super(PricesLoading()) {
    on<LoadPrices>(_onLoadPrices);
    on<AddCustomPrice>(_onAddCustomPrice);
    on<DeleteCustomPrice>(_onDeleteCustomPrice);
  }

  final PriceRepository _priceRepository;
  final CustomListDao _customListDao = CustomListDao();

  Future<void> _onLoadPrices(
      LoadPrices event, Emitter<PricesState> emit) async {
    // Show loading only if it's the first load or explicit refresh
    if (state is! PricesLoaded) {
      emit(PricesLoading());
    }

    try {
      // Repository handles fetching from internet or fallback to DB
      await _priceRepository.refresh();

      final customPrices = await _customListDao.getSelectedWealthPrices();
      
      // Update custom prices if we have any processed derived prices (like silver)
      List<WealthPrice> customLists = List<WealthPrice>.from(customPrices);
      
      // Check if silver is in custom lists and update it from the fresh repository data
      final silverInRepo = _priceRepository.commodityPrices.firstWhere(
        (p) => p.title.toLowerCase().contains('gümüş'),
        orElse: () => _priceRepository.commodityPrices.first, // fallback
      );

      if (silverInRepo.title.contains('Gümüş (TL/GR)')) {
          for (int i = 0; i < customLists.length; i++) {
            if (customLists[i].title.toLowerCase().contains('gümüş')) {
              customLists[i] = silverInRepo;
            }
          }
      }

      emit(PricesLoaded(
        commodityPrices: _priceRepository.commodityPrices,
        goldPrices: _priceRepository.goldPrices,
        currencyPrices: _priceRepository.currencyPrices,
        equityPrices: _priceRepository.equityPrices,
        customPrices: customLists,
        lastUpdatedAt: _priceRepository.lastUpdatedAt,
        isFromCache: _priceRepository.isFromCache,
      ));
    } catch (e) {
      emit(PricesError(LocaleKeys.failedToLoadPrices.tr(namedArgs: {'error': e.toString()})));
    }
  }

  Future<void> _onAddCustomPrice(
      AddCustomPrice event, Emitter<PricesState> emit) async {
    if (state is PricesLoaded) {
      final currentState = state as PricesLoaded;
      List<WealthPrice> updatedCustomPrices =
          List<WealthPrice>.from(currentState.customPrices);
      List<String> duplicates = [];

      for (var wealthPrice in event.wealthPrices) {
        if (!updatedCustomPrices.contains(wealthPrice)) {
          await _customListDao.insertWealthPrice(wealthPrice);
          updatedCustomPrices.add(wealthPrice);
        } else {
          duplicates.add(wealthPrice.title);
        }
      }

      if (duplicates.isNotEmpty) {
        emit(CustomPriceDuplicateError(LocaleKeys.itemsAlreadyExist.tr(namedArgs: {'items': duplicates.join(', ')})));
      }
      emit(currentState.copyWith(customPrices: updatedCustomPrices));
    }
  }

  Future<void> _onDeleteCustomPrice(
      DeleteCustomPrice event, Emitter<PricesState> emit) async {
    if (state is PricesLoaded) {
      final currentState = state as PricesLoaded;

      await _customListDao.deleteWealthPrice(event.wealthPrice);

      final updatedCustomPrices =
          List<WealthPrice>.from(currentState.customPrices)
            ..remove(event.wealthPrice);

      emit(currentState.copyWith(customPrices: updatedCustomPrices));
    }
  }
}
