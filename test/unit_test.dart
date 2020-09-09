import 'dart:async';
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:check_prices/BLoC/keyboard/keyboard_cubit.dart';
import 'package:check_prices/BLoC/products/products_bloc.dart';
import 'package:check_prices/models/models.dart';
import 'package:check_prices/repo/data_providers.dart';
import 'package:check_prices/repo/repository.dart';

final product = Product(
  title: '',
  subtitle: '',
  brand: '',
  url: '',
  imageUrl: '',
  regularPrice: '',
  cardPrice: [],
  logo: '',
);

class FakeDataProviderAllErrors extends Fake implements DataProvider {
  @override
  Future<List<Product>> fetchLentaData({String search}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> fetchMetroData({String search}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> fetch5kaData({String search}) {
    throw UnimplementedError();
  }
}

class FakeDataProviderAllGood extends Fake implements DataProvider {
  @override
  Future<List<Product>> fetchLentaData({String search}) async {
    return [product];
  }

  @override
  Future<List<Product>> fetchMetroData({String search}) async {
    return [product];
  }

  @override
  Future<List<Product>> fetch5kaData({String search}) async {
    return [product];
  }
}

void main() {
  DataProvider fakeDataProviderAllErrors;
  DataProvider fakeDataProviderAllGood;
  Repository repositoryAllErrors;
  Repository repositoryAllGood;
  List<Product> matcherList = [product, product, product];

  setUp(() {
    fakeDataProviderAllErrors = FakeDataProviderAllErrors();
    fakeDataProviderAllGood = FakeDataProviderAllGood();
    repositoryAllErrors = Repository(dataProvider: fakeDataProviderAllErrors);
    repositoryAllGood = Repository(dataProvider: fakeDataProviderAllGood);
  });

  group('Products BLoC ->', () {
    blocTest<ProductsBloc, ProductsState>(
      'initial ProductState',
      build: () => ProductsBloc(repository: repositoryAllGood),
      expect: [],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductsLoadInProgress, ProductsLoaded] when ProductsEvent.ProductsFetched is added',
      build: () => ProductsBloc(repository: repositoryAllGood),
      act: (bloc) => bloc.add(ProductsFetched(search: '')),
      wait: Duration(seconds: 1),
      expect: [
        isA<ProductsLoadInProgress>(),
        isA<ProductsLoaded>(),
      ],
    );
  });

  group('Keyboard Cubit ->', () {
    blocTest(
      'initial state of Cubit',
      build: () => KeyboardCubit(),
      expect: [],
    );

    blocTest<KeyboardCubit, bool>(
        'emit [true] when call readOnlyKeyboard(true);',
        build: () => KeyboardCubit(),
        act: (cubit) => cubit.readOnlyKeyboard(true),
        expect: [true]);
  });

  group('Repository ->', () {
    test('check type & keys of recieved data from repository.fetchAll',
        () async {
      Map<String, List<dynamic>> map =
          await repositoryAllGood.fetchAll(search: '');
      expect(map, isA<Map<String, List<dynamic>>>());
      expect(map.containsKey('products'), true,
          reason: '--> Key "products" did\'t match');
      expect(map.containsKey('errors'), true,
          reason: '--> Key "errors" did\'t match');
    });

    test(
        'emit {products: [], errors: [\'lenta\', \'metro\', \'5ka\']} when repository.fetchAll',
        () async {
      Map<String, List<dynamic>> map =
          await repositoryAllErrors.fetchAll(search: '');
      expect(map, isA<Map<String, List<dynamic>>>());
      expect(map['products'].length, 0);
      expect(map['errors'].length, 3);
      expect(map['errors'], ['lenta', 'metro', '5ka']);
    });

    test(
        'emit {products: [Product(), Product(), Product()], errors: []} when repository.fetchAll',
        () async {
      Map<String, List<dynamic>> map =
          await repositoryAllGood.fetchAll(search: '');

      expect(map, isA<Map<String, List<dynamic>>>());
      expect(listEquals(map['products'], matcherList), true);
      expect(map['products'].length == 3, true);
      expect(map['errors'].length, 0);
    });
  });

  group('Models ->', () {
    List<Map<String, dynamic>> testJsonPrice = [
      {'count': 12, 'price': 37.9}
    ];
    test('test funcs ', () {
      expect(updatePrice(15.1), '15.10 руб.');
      expect(updatePackingType('штука'), ' шт ');
      expect(updatePackingType('штуки'), ' шт ');
      expect(updatePackingType('упаковка'), ' уп ');
      expect(updatePackingType('упаковок'), ' уп ');
      expect(updatePackingType('кг'), ' кг ');
      expect(list(testJsonPrice, ' шт ')[0].price, 'от 12 шт 37.90 руб.');
    });
    group('check structure of data from requests ->', () {
      String search = 'молоко';
      Map<String, String> headers = {'Content-type': 'application/json'};
      final uriLenta =
          Uri.parse('https://lenta.com/api/v1/search?value=$search');
      final uriMetro = Uri.parse(
          'https://api.metro-cc.ru/api/v1/C98BB1B547ECCC17D8AEBEC7116D6/39/suggestions?query=$search');
      final uri5kaDomain = Uri.parse('https://5ka.ru');
      final uri5ka =
          Uri.parse('https://5ka.ru/api/v2/special_offers/?search=$search');
      var response, json;

      test('lenta', () async {
        response = await Requests.getHttp(url: uriLenta, headers: headers);
        json = jsonDecode(response.body)['skus'][0];
        expect(json.containsKey('title'), true);
        expect(json.containsKey('subTitle'), true);
        expect(json.containsKey('url'), true);
        expect(json.containsKey('imageUrl'), true);
        expect(json.containsKey('brand'), true);
        expect(json.containsKey('regularPrice'), true);
        expect(json['regularPrice'].containsKey('value'), true);
        expect(json['cardPrice'].containsKey('value'), true);
      });
      test('metro', () async {
        response = await Requests.getHttp(url: uriMetro, headers: headers);
        json = jsonDecode(response.body)['data']['topProducts'][0];
        expect(json.containsKey('name'), true);
        expect(json.containsKey('packing'), true);
        expect(json['packing'].containsKey('size'), true);
        expect(json['packing'].containsKey('type'), true);
        expect(json.containsKey('url'), true);
        expect(json.containsKey('images'), true);
        expect(json.containsKey('manufacturer'), true);
        expect(json.containsKey('prices'), true);
        expect(json['prices'].containsKey('price'), true);
        if (json['manufacturer'].isNotEmpty) {
          expect(json['manufacturer'].containsKey('name'), true);
        }
        if (json['prices'].containsKey('levels')) {
          expect(json['prices']['levels'][0].containsKey('count'), true);
          expect(json['prices']['levels'][0].containsKey('price'), true);
        }
      });
      test('5ka', () async {
        response = await Requests.getHttp(url: uri5kaDomain, headers: headers);
        headers['Cookie'] =
            'location_id=1871; Path=/,' + response.headers['set-cookie'];
        response = await Requests.getHttp(url: uri5ka, headers: headers);
        json = jsonDecode(utf8.decode(response.bodyBytes))['results'];
        expect(json.isNotEmpty, true, reason: 'Нет акций по: $search');
        expect(json[0].containsKey('name'), true);
        expect(json[0].containsKey('id'), true);
        expect(json[0].containsKey('current_prices'), true);
        expect(json[0]['current_prices'].containsKey('price_promo__min'), true);
      });
    });
  });
}
