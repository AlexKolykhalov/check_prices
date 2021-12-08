import 'dart:async';
import 'dart:convert';

import 'package:check_prices/models/models.dart';
import 'package:http/http.dart' as http_client;

///Описывает общий request GET с конструкцией try catch
mixin Requests {
  static getHttp({
    required Uri url,
    required Map<String, String> headers,
  }) async {
    try {
      http_client.Response response = await http_client
          .get(url, headers: headers)
          .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception();
      }
    } on TimeoutException catch (_) {
      throw Exception();
    }
  }
}

class DataProvider with Requests {
  /// Функция, которая создает List из
  /// результат запроса result к API магазина,
  /// параметр shop 'lenta' или 'metro'
  List<Product> mapProducts({result, shop}) {
    return result
        .map<Product>((element) =>
            Product.fromEntity(ProductEntity.fromJson(element, shop)))
        .toList();
  }

  Future<List<Product>> fetchLentaData({required String search}) async {
    Map<String, String> headers = {'Content-type': 'application/json'};
    Uri urlDomain = Uri.parse('https://lenta.com');
    Uri urlSearch = Uri.parse('https://lenta.com/api/v1/search?value=$search');
    String cookie = ';lentaT2=lpc; Store=0148; CityCookie=lpc';

    var response = await Requests.getHttp(url: urlDomain, headers: headers);
    headers['Cookie'] = response.headers['set-cookie'] + cookie;
    response = await Requests.getHttp(url: urlSearch, headers: headers);
    var result = jsonDecode(response.body)['skus'];

    return mapProducts(result: result, shop: 'lenta');
  }

  Future<List<Product>> fetchMetroData({required String search}) async {
    Map<String, String> headers = {'Content-type': 'application/json'};
    Uri urlSearch = Uri.parse(
        'https://api.metro-cc.ru/api/v1/C98BB1B547ECCC17D8AEBEC7116D6/39/suggestions?query=$search');

    var response = await Requests.getHttp(url: urlSearch, headers: headers);
    var result = jsonDecode(response.body)['data']['topProducts'];

    return mapProducts(result: result, shop: 'metro');
  }

  Future<List<Product>> fetch5kaData({required String search}) async {
    Map<String, String> headers = {'Content-type': 'application/json'};

    Uri urlDomain = Uri.parse('https://5ka.ru');
    Uri urlSearch =
        Uri.parse('https://5ka.ru/api/v2/special_offers/?search=$search');

    var response = await Requests.getHttp(url: urlDomain, headers: headers);
    headers['Cookie'] =
        'location_id=1871; Path=/,' + response.headers['set-cookie'];

    response = await Requests.getHttp(url: urlSearch, headers: headers);
    var result = jsonDecode(utf8.decode(response.bodyBytes))['results'];

    return mapProducts(result: result, shop: '5ka');
  }

  Future<List<Product>> fetchAuchanData({required String search}) async {
    Map<String, String> headers = {'Content-type': 'application/json'};
    //merchantId=15 (магазин в Москве Сокольники), магазина в Липецке нет по
    // списку на https://www.auchan.ru/v1/shops

    Uri urlSearch =
        Uri.parse('https://auchan.ru/v1/search?query=$search&merchantId=15');

    var response = await Requests.getHttp(url: urlSearch, headers: headers);
    var result = jsonDecode(response.body)['items']
        .values
        .toList()[0]['products']
        .take(10)
        .toList();

    return mapProducts(result: result, shop: 'auchan');
  }
}
