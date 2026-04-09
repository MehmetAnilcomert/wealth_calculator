import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_bloc.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_event.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_state.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/product/service/data_scraping_service.dart';

class MockDataScrapingService extends Mock implements DataScrapingService {}

void main() {
  late CalculatorBloc calculatorBloc;
  late MockDataScrapingService mockDataScrapingService;

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
    mockDataScrapingService = MockDataScrapingService();
    calculatorBloc =
        CalculatorBloc(dataScrapingService: mockDataScrapingService);
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
      build: () {
        when(() => mockDataScrapingService.fetchGoldPrices())
            .thenAnswer((_) async => sampleGoldPrices);
        when(() => mockDataScrapingService.fetchCurrencyPrices())
            .thenAnswer((_) async => sampleCurrencyPrices);
        return calculatorBloc;
      },
      act: (bloc) => bloc.add(const LoadCalculatorData()),
      expect: () => [
        isA<CalculatorLoading>(),
        isA<CalculatorLoaded>()
            .having((s) => s.goldPrices, 'goldPrices', sampleGoldPrices),
      ],
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'emits [CalculatorLoading, CalculatorError] when fetching fails',
      build: () {
        when(() => mockDataScrapingService.fetchGoldPrices())
            .thenThrow(Exception('Network Error'));
        return calculatorBloc;
      },
      act: (bloc) => bloc.add(const LoadCalculatorData()),
      expect: () => [
        isA<CalculatorLoading>(),
        isA<CalculatorError>(),
      ],
    );
  });

  group('AddOrUpdateCalculatorWealth Event', () {
    final goldWealth = SavedWealths(id: 1, type: 'Gram Altın', amount: 10.0);

    blocTest<CalculatorBloc, CalculatorState>(
      'updates total price correctly when adding new wealth',
      setUp: () {
        when(() => mockDataScrapingService.fetchGoldPrices())
            .thenAnswer((_) async => sampleGoldPrices);
        when(() => mockDataScrapingService.fetchCurrencyPrices())
            .thenAnswer((_) async => sampleCurrencyPrices);
      },
      build: () => calculatorBloc,
      act: (bloc) async {
        bloc.add(const LoadCalculatorData());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(AddOrUpdateCalculatorWealth(goldWealth, 10.0));
      },
      skip: 2,
      expect: () => [
        isA<CalculatorLoaded>()
            .having((s) => s.totalPrice, 'Final Total', 25000.0),
      ],
    );

    blocTest<CalculatorBloc, CalculatorState>(
      'updates existing wealth amount instead of adding new',
      setUp: () {
        when(() => mockDataScrapingService.fetchGoldPrices())
            .thenAnswer((_) async => sampleGoldPrices);
        when(() => mockDataScrapingService.fetchCurrencyPrices())
            .thenAnswer((_) async => sampleCurrencyPrices);
      },
      build: () => calculatorBloc,
      act: (bloc) async {
        bloc.add(const LoadCalculatorData());
        await expectLater(bloc.stream, emitsThrough(isA<CalculatorLoaded>()));
        bloc.add(AddOrUpdateCalculatorWealth(goldWealth, 10.0));
        await expectLater(bloc.stream, emitsThrough(isA<CalculatorLoaded>()));
        bloc.add(AddOrUpdateCalculatorWealth(goldWealth, 20.0));
      },
      skip: 3,
      expect: () => [
        isA<CalculatorLoaded>()
            .having((s) => s.totalPrice, 'Updated Total', 50000.0),
      ],
    );
  });

  group('DeleteCalculatorWealth Event', () {
    final goldWealth = SavedWealths(id: 1, type: 'Gram Altın', amount: 10.0);

    blocTest<CalculatorBloc, CalculatorState>(
      'removes wealth and updates total price',
      setUp: () {
        when(() => mockDataScrapingService.fetchGoldPrices())
            .thenAnswer((_) async => sampleGoldPrices);
        when(() => mockDataScrapingService.fetchCurrencyPrices())
            .thenAnswer((_) async => sampleCurrencyPrices);
      },
      build: () => calculatorBloc,
      act: (bloc) async {
        bloc.add(const LoadCalculatorData());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(AddOrUpdateCalculatorWealth(goldWealth, 10.0));
        await Future.delayed(const Duration(milliseconds: 100));

        // ÖNEMLİ: Bloc'un ürettiği gerçek ID'yi state'ten alıyoruz!
        final currentState = bloc.state as CalculatorLoaded;
        final actualId = currentState.savedWealths.first.id;

        bloc.add(DeleteCalculatorWealth(actualId));
      },
      expect: () => [
        isA<CalculatorLoading>(),
        isA<CalculatorLoaded>().having((s) => s.totalPrice, 'Empty', 0.0),
        isA<CalculatorLoaded>().having((s) => s.totalPrice, 'Added', 25000.0),
        isA<CalculatorLoaded>().having((s) => s.totalPrice, 'Deleted', 0.0),
      ],
    );
  });

  group('Logic verification (Segments & Colors)', () {
    blocTest<CalculatorBloc, CalculatorState>(
      'emits Loaded with correct segments and colors',
      setUp: () {
        when(() => mockDataScrapingService.fetchGoldPrices())
            .thenAnswer((_) async => sampleGoldPrices);
        when(() => mockDataScrapingService.fetchCurrencyPrices())
            .thenAnswer((_) async => sampleCurrencyPrices);
      },
      build: () => calculatorBloc,
      act: (bloc) async {
        final goldWealth =
            SavedWealths(id: 1, type: 'Gram Altın', amount: 10.0);
        final usdWealth =
            SavedWealths(id: 2, type: 'ABD Doları', amount: 100.0);

        bloc.add(const LoadCalculatorData());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(AddOrUpdateCalculatorWealth(goldWealth, 10.0));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(AddOrUpdateCalculatorWealth(usdWealth, 100.0));
      },
      // States: Loading, Loaded(base), Loaded(gold), Loaded(both)
      skip: 3,
      expect: () => [
        isA<CalculatorLoaded>()
            .having(
              (s) => s.segments.length,
              'segments count',
              2,
            )
            .having(
              (s) => s.segments.reduce((a, b) => a + b),
              'segments sum',
              closeTo(360, 0.1),
            ),
      ],
    );
  });
}
