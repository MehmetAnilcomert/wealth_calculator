import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/product.dart';

// Prices screen`s state class
class PricesScreenState {
  final int currentTabIndex;
  final String searchQuery;

  PricesScreenState({
    this.currentTabIndex = 0,
    this.searchQuery = '',
  });

  PricesScreenState copyWith({
    int? currentTabIndex,
    String? searchQuery,
  }) {
    return PricesScreenState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Prices screen`s cubit class to manage state
class PricesScreenCubit extends BaseCubit<PricesScreenState> {
  late TabController _tabController;

  PricesScreenCubit() : super(PricesScreenState());

  void initTabController(TickerProvider vsync) {
    _tabController = TabController(length: 5, vsync: vsync);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      emit(state.copyWith(currentTabIndex: _tabController.index));
    }
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
