// import 'package:flutter/material.dart';

import 'package:check_prices/models/models.dart';
import 'package:check_prices/repo/data_providers.dart';

class Repository {
  Repository({required DataProvider dataProvider})
      : _dataProvider = dataProvider;

  final DataProvider _dataProvider;

  Future<List> fetchAll({required String search}) async {
    List<Product> _products = [];
    List<String> _errors = [];

    try {
      final List<Product> lentaData =
          await _dataProvider.fetchLentaData(search: search);
      _products.addAll(lentaData);
    } catch (e) {
      _errors.add('lenta');
    }
    try {
      final List<Product> metroData =
          await _dataProvider.fetchMetroData(search: search);
      _products.addAll(metroData);
    } catch (e) {
      _errors.add('metro');
    }
    try {
      final List<Product> pkaData =
          await _dataProvider.fetch5kaData(search: search);
      _products.addAll(pkaData);
    } catch (e) {
      _errors.add('5ka');
    }
    try {
      final List<Product> auchanData =
          await _dataProvider.fetchAuchanData(search: search);
      _products.addAll(auchanData);
    } catch (e) {
      _errors.add('auchan');
    }

    if (_products.isNotEmpty) {
      _products.sort((a, b) => a.title.compareTo(b.title));
    }

    return [_products, _errors];
  }
}
