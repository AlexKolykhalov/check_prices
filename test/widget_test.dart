import 'package:check_prices/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:check_prices/BLoC/keyboard/keyboard_cubit.dart';
import 'package:check_prices/BLoC/products/products_bloc.dart';
import 'package:check_prices/repo/repository.dart';
import 'package:check_prices/main.dart';

class FakeRepository extends Fake implements Repository {
  @override
  Future<Map<String, List<dynamic>>> fetchAll({String search}) async {
    return Future.delayed(
        Duration(seconds: 1), () => {'products': [], 'errors': []});
  }
}

void main() {
  ProductsBloc _bloc;
  Repository _repository;
  MaterialApp _app;

  setUp(() {
    _repository = FakeRepository();
    _bloc = ProductsBloc(repository: _repository);
    _app = MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => _bloc),
          BlocProvider(create: (context) => KeyboardCubit())
        ],
        child: SafeArea(child: HomePage()),
      ),
    );
  });
  tearDown(() {
    _bloc.close();
  });

  testWidgets('availability widgets in Home page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Поиск...'), findsOneWidget);
    expect(find.text('Начните поиск.'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);
  });

  testWidgets('enter a text in TextField', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.enterText(find.byType(TextField), 'молоко');
    await tester.pump(Duration(milliseconds: 1000));

    expect(find.text('молоко'), findsOneWidget);
  });

  testWidgets(
      'return CircularProgressIndicator when emit [ProductsLoadInProgress]',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _bloc.emit(ProductsLoadInProgress());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'return \'Ничего не найдено.\' when emit [{\'products\': [], \'errors\': []}]',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _bloc.emit(ProductsLoaded(data: {'products': [], 'errors': []}));
    await tester.pump();

    expect(find.text('Ничего не найдено.'), findsOneWidget);
  });

  testWidgets(
      'return SnackBar when emit [{\'products\': [], \'errors\': [\'lenta\']}]',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _bloc.emit(ProductsLoaded(data: {
      'products': [],
      'errors': ['lenta']
    }));
    await tester.pump();

    expect(find.text('Ничего не найдено.'), findsOneWidget);
    expect(find.text('Ошибка при получении данных:'), findsOneWidget);
  });

  testWidgets(
      'to show close & refresh icons when emit [{\'products\': [], \'errors\': [\'lenta\']}]',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _bloc.emit(ProductsLoaded(data: {
      'products': [],
      'errors': ['lenta']
    }));
    await tester.pump();

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets(
      'return ListView when emit [{\'products\': [Product(...)], \'errors\': []}]',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app);
    _bloc.emit(ProductsLoaded(data: {
      'products': [
        Product(
          title: '',
          subtitle: '',
          brand: '',
          url: '',
          imageUrl: '',
          cardPrice: [],
          regularPrice: '',
          logo: 'assets/5ka_fav.png',
        )
      ],
      'errors': []
    }));
    await tester.pump();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Ошибка при получении данных:'), findsNothing);
  });
}
