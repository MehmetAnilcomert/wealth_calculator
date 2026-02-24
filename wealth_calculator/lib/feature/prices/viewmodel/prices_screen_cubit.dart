import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/product.dart';

// Prices screen`s state class
class PricesScreenState {
  final int currentTabIndex;
  final String searchQuery;
  final bool isPortfolioActive;

  PricesScreenState({
    this.currentTabIndex = 0,
    this.searchQuery = '',
    this.isPortfolioActive = false,
  });

  PricesScreenState copyWith({
    int? currentTabIndex,
    String? searchQuery,
    bool? isPortfolioActive,
  }) {
    return PricesScreenState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      isPortfolioActive: isPortfolioActive ?? this.isPortfolioActive,
    );
  }
}

// Prices screen`s cubit class to manage state
class PricesScreenCubit extends BaseCubit<PricesScreenState> {
  late TabController _tabController;

  PricesScreenCubit() : super(PricesScreenState());

  void initTabController(TickerProvider vsync) {
    _tabController = TabController(length: 4, vsync: vsync);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (state.currentTabIndex != _tabController.index) {
      emit(state.copyWith(
        currentTabIndex: _tabController.index,
        isPortfolioActive: false,
      ));
    }
  }

  void setPortfolioActive(bool active) {
    emit(state.copyWith(isPortfolioActive: active));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  TabController get tabController => _tabController;

  @override
  Future<void> close() {
    _tabController.dispose();
    return super.close();
  }
}
