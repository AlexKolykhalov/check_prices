import 'package:check_prices/models/models.dart';
import 'package:check_prices/repo/data_providers.dart';

class Repository {
  final _dataProvider = DataProvider();

  Future<Map<String, List<dynamic>>> fetchAll({String search}) async {
    Map<String, List<dynamic>> data = {'products': [], 'errors': []};
    List<Product> lentaData, metroData, pkaData;
    try {
      lentaData = await _dataProvider.fetchLentaData(search: search);
      data['products'].addAll(lentaData);
    } catch (e) {
      lentaData = [];
      data['errors'].add('lenta');
    }
    try {
      metroData = await _dataProvider.fetchMetroData(search: search);
      data['products'].addAll(metroData);
    } catch (e) {
      metroData = [];
      data['errors'].add('metro');
    }
    try {
      pkaData = await _dataProvider.fetch5kaData(search: search);
      data['products'].addAll(pkaData);
    } catch (e) {
      pkaData = [];
      data['errors'].add('5ka');
    }
    if (data['products'].isNotEmpty) {
      data['products'].sort((a, b) => a.title.compareTo(b.title));
    }
    return data;
  }
}
