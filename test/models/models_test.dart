import 'dart:convert';

import 'package:check_prices/models/models.dart';
import 'package:check_prices/repo/data_providers.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

main() {
  test('test func updatePrice()', () {
    expect(updatePrice(15.1), '15.10 руб.');
  });

  test('test func updatePackingType()', () {
    expect(updatePackingType('штука'), ' шт ');
    expect(updatePackingType('штуки'), ' шт ');
    expect(updatePackingType('упаковка'), ' уп ');
    expect(updatePackingType('упаковок'), ' уп ');
    expect(updatePackingType('кг'), ' кг ');
  });

  test('test CardPriceEntity.fromJson()', () {
    final CardPriceEntity actual = CardPriceEntity.fromJson(
        {'count': 12, 'price': 37.9}, updatePackingType('штуки'));
    const String matcher = 'от 12 шт 37.90 руб.';
    expect(actual.price, matcher);
  });

  group('test data structure', () {
    String search = 'молоко';
    Map<String, String> headers = {'Content-type': 'application/json'};
    final uriLenta = Uri.parse('https://lenta.com/api/v1/search?value=$search');
    final uriMetro = Uri.parse(
        'https://api.metro-cc.ru/api/v1/C98BB1B547ECCC17D8AEBEC7116D6/39/suggestions?query=$search');
    final uri5kaDomain = Uri.parse('https://5ka.ru');
    final uri5ka =
        Uri.parse('https://5ka.ru/api/v2/special_offers/?search=$search');
    final uriAuchan =
        Uri.parse('https://auchan.ru/v1/search?query=$search&merchantId=15');

    dynamic response, json;

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

    test('auchan', () async {
      response = await Requests.getHttp(url: uriAuchan, headers: headers);
      json = jsonDecode(response.body)['items']
          .values
          .toList()[0]['products']
          .take(10)
          .toList()[0];
      expect(json.containsKey('name'), true);
      expect(json.containsKey('code'), true);
      expect(json.containsKey('brandName'), true);
      expect(json.containsKey('price'), true);
      expect(json['price'].containsKey('value'), true);
    });
  });
}
