import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_bloc.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_event.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_state.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/product/service/price_repository.dart';

class MockPriceRepository extends Mock implements PriceRepository {}

void main() {
  late CalculatorBloc calculatorBloc;
  late MockPriceRepository mockPriceRepository;

  final sampleGoldPrices = [
    WealthPrice(
      title: 'Gram Altın',
      buyingPrice: '2.500,00',
      sellingPrice: '2.550,00',
      change: '1%',
      time: '12:00',
      type: PriceType.gold,
    ),
  ];

  final sampleCurrencyPrices = [
    WealthPrice(
      title: 'ABD Doları',
      buyingPrice: '32,50',
      sellingPrice: '32,80',
      change: '0.5%',
      time: '12:00',
      type: PriceType.currency,
    ),
  ];

  setUp(() {
    mockPriceRepository = MockPriceRepository();
    
    // Default stubbing
    when(() => mockPriceRepository.goldPrices).thenReturn(sampleGoldPrices);
    when(() => mockPriceRepository.currencyPrices).thenReturn(sampleCurrencyPrices);
    when(() => mockPriceRepository.lastUpdatedAt).thenReturn(DateTime(2024, 1, 1));
    when(() => mockPriceRepository.isFromCache).thenReturn(false);
    when(() => mockPriceRepository.refresh()).thenAnswer((_) async {});

    calculatorBloc = CalculatorBloc(priceRepository: mockPriceRepository);
  });

  tearDown(() {
    calculatorBloc.close();
  });

  group('CalculatorBloc Initial State', () {
    test('initial state is CalculatorInitial', () {
      expect(calculatorBloc.state, isA<CalculatorInitial>());
    });
  });

  group('LoadCalculatorData Event', () {
    blocTest<CalculatorBloc, CalculatorState>(
      'emits [CalculatorLoading, CalculatorLoaded] when data is loaded successfully',
      build: () => calculatorBloc,
      act: (bloc) => bloc.add(const LoadCalculatorData()),
      expect: () => [
        isA<CalculatorLoading>(),
        isA<CalculatorLoaded>()
            .having((s) => s.goldPrices, 'goldPrices', sampleGoldPrices),
      ],
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'emits [CalculatorLoading, CalculatorError] when refreshing fails',
      setUp: () {
        when(() => mockPriceRepository.goldPrices).thenReturn([]);
        when(() => mockPriceRepository.currencyPrices).thenReturn([]);
        when(() => mockPriceRepository.refresh()).thenThrow(Exception('Network Error'));
      },
      build: () => calculatorBloc,
      act: (bloc) => bloc.add(const LoadCalculatorData()),
      expect: () => [
        isA<CalculatorLoading>(),
        isA<CalculatorError>(),
      ],
    );
  });

  group('AddOrUpdateCalculatorWealth Event', () {
    final goldWealth = SavedWealths(id: 1, type: 'Gram Altın', amount: 10.0);
    final goldPriceModel = WealthPrice(
      title: 'Gram Altın',
      buyingPrice: '2.500,00',
      sellingPrice: '2.550,00',
      change: '1%',
      time: '12:00',
      type: PriceType.gold,
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'updates total price correctly when adding new wealth using WealthPrice',
      build: () => calculatorBloc,
      act: (bloc) => bloc.add(AddOrUpdateCalculatorWealth(goldPriceModel, 10.0)),
      expect: () => [
        isA<CalculatorLoaded>()
            .having((s) => s.totalPrice, 'Final Total', 25000.0),
      ],
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'updates total price correctly when add/update using SavedWealths',
      build: () => calculatorBloc,
      act: (bloc) => bloc.add(AddOrUpdateCalculatorWealth(goldWealth, 20.0)),
      expect: () => [
        isA<CalculatorLoaded>()
            .having((s) => s.totalPrice, 'Final Total', 50000.0),
      ],
    );
  });

  group('DeleteCalculatorWealth Event', () {
    blocTest<CalculatorBloc, CalculatorState>(
      'removes wealth and updates total price',
      build: () => calculatorBloc,
      act: (bloc) async {
        final goldPriceModel = WealthPrice(
          title: 'Gram Altın',
          buyingPrice: '2.500,00',
          sellingPrice: '2.550,00',
          change: '1%',
          time: '12:00',
          type: PriceType.gold,
        );
        
        bloc.add(AddOrUpdateCalculatorWealth(goldPriceModel, 10.0));
        await expectLater(bloc.stream, emitsThrough(isA<CalculatorLoaded>()));
        
        final currentState = bloc.state as CalculatorLoaded;
        final actualId = currentState.savedWealths.first.id;

        bloc.add(DeleteCalculatorWealth(actualId));
      },
      skip: 1, // Skip initial add result
      expect: () => [
        isA<CalculatorLoaded>().having((s) => s.totalPrice, 'Deleted', 0.0),
      ],
    );
  });
}
