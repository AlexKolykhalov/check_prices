import 'package:check_prices/BLoC/product/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:check_prices/BLoC/product/product_state.dart';
import 'package:check_prices/BLoC/textfield/textfield_cubit.dart';
import 'package:check_prices/main.dart';
import 'package:check_prices/models/models.dart';

void main() {
  late ProductCubit _productCubit;
  late MaterialApp _app;

  setUp(() {
    _productCubit = ProductCubit();
    _app = MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => _productCubit),
          BlocProvider(create: (context) => TextFieldCubit())
        ],
        child: SafeArea(child: HomePage()),
      ),
    );
  });

  tearDown(() {
    _productCubit.close();
  });

  testWidgets('availability widgets in Home page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Поиск...'), findsOneWidget);
    expect(find.text('Начните поиск.'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.refresh), findsNothing);
  });

  testWidgets('enter a text in TextField', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.enterText(find.byType(TextField), 'молоко');
    await tester.pump(Duration(milliseconds: 1000));
    expect(find.text('молоко'), findsOneWidget);
  });

  testWidgets('return CircularProgressIndicator when emit [Loading]',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _productCubit.emit(Loading());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'return \'Ничего не найдено.\' when emit [Loaded(products: [], errors: [])]',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _productCubit.emit(Loaded(products: [], errors: []));
    await tester.pump();

    expect(find.text('Ничего не найдено.'), findsOneWidget);
  });

  testWidgets(
      'return SnackBar when emit [Loaded(products: [], errors: ["lenta"])',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _productCubit.emit(Loaded(products: [], errors: ['lenta']));
    await tester.pump();

    expect(find.text('Ничего не найдено.'), findsOneWidget);
    expect(find.text('Ошибка при получении данных:'), findsOneWidget);
  });

  testWidgets(
      'show close & refresh icons when emit [Loaded(products: [], errors: ["lenta"])',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _productCubit.emit(Loaded(products: [], errors: ['lenta']));
    await tester.pump();

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets(
      'return ListView when emit [{\'products\': [Product(...)], \'errors\': []}]',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _productCubit.emit(
      Loaded(
        products: [
          Product(
            title: '',
            subtitle: '',
            brand: '',
            url: '',
            imageUrl: '',
            cardPrice: [],
            regularPrice: '',
            logo: '5ka',
          )
        ],
        errors: [],
      ),
    );
    await tester.pump();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Ошибка при получении данных:'), findsNothing);
  });
}
