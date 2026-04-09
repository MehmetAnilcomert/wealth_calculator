import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wealth_calculator/feature/calculator/view/calculator_view.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_bloc.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_event.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_state.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

// Mocks
class MockCalculatorBloc extends MockBloc<CalculatorEvent, CalculatorState>
    implements CalculatorBloc {}

void main() {
  late MockCalculatorBloc mockCalculatorBloc;

  setUp(() {
    mockCalculatorBloc = MockCalculatorBloc();
    when(() => mockCalculatorBloc.state).thenReturn(CalculatorLoading());
  });

  // Helper to set a consistent screen size for widget tests to avoid overflows
  Future<void> setScreenSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CalculatorView(bloc: mockCalculatorBloc),
    );
  }

  group('CalculatorView Widget Tests', () {
    testWidgets('renders CircularProgressIndicator when state is CalculatorLoading',
        (WidgetTester tester) async {
      await setScreenSize(tester);
      when(() => mockCalculatorBloc.state).thenReturn(CalculatorLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders List and TotalPrice when state is CalculatorLoaded',
        (WidgetTester tester) async {
      await setScreenSize(tester);
      final loadedState = CalculatorLoaded(
        totalPrice: 1000.0,
        segments: [180.0, 180.0],
        colors: [Colors.red, Colors.blue],
        goldPrices: const [],
        currencyPrices: const [],
        savedWealths: [
          SavedWealths(id: 1, type: 'Gram Altın', amount: 10.0),
        ],
      );
      when(() => mockCalculatorBloc.state).thenReturn(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // pump() yerine pumpAndSettle animasyonların bitmesini bekler

      expect(find.textContaining('1.000'), findsOneWidget); 
      expect(find.byType(FloatingActionButton), findsOneWidget); 
      expect(find.text('Gram Altın'), findsOneWidget);
    });

    testWidgets('renders error text when state is CalculatorError',
        (WidgetTester tester) async {
      await setScreenSize(tester);
      when(() => mockCalculatorBloc.state).thenReturn(const CalculatorError('Error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('error'), findsOneWidget); 
    });

    testWidgets('app bar title and FAB presence', (WidgetTester tester) async {
      await setScreenSize(tester);
      final loadedState = CalculatorLoaded(
        totalPrice: 0.0,
        segments: const [],
        colors: const [],
        goldPrices: const [],
        currencyPrices: const [],
        savedWealths: const [],
      );
      when(() => mockCalculatorBloc.state).thenReturn(loadedState);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      // Top AppBar + SliverAppBar = 2 AppBars
      expect(find.byType(AppBar), findsNWidgets(2));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
