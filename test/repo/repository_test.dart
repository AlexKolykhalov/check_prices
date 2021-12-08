import 'package:check_prices/models/models.dart';
import 'package:check_prices/repo/data_providers.dart';
import 'package:check_prices/repo/repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class DataProviderMock extends Mock implements DataProvider {
  static const product = Product(
      title: '',
      subtitle: '',
      url: '',
      imageUrl: '',
      brand: '',
      regularPrice: '',
      cardPrice: [],
      logo: '');

  @override
  Future<List<Product>> fetchLentaData({required String search}) async {
    return [product];
  }

  @override
  Future<List<Product>> fetchMetroData({required String search}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> fetch5kaData({required String search}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> fetchAuchanData({required String search}) async {
    return [product];
  }
}

main() {
  late Repository repository;

  setUp(() {
    repository = Repository(dataProvider: DataProviderMock());
  });

  group('test func fetchAll', () {
    test('repository.fetchAll() is List', () async {
      List list = await repository.fetchAll(search: '');
      expect(list, isA<List>());
    });

    test('get 2 products', () async {
      List list = await repository.fetchAll(search: '');
      expect((list[0] as List).length, 2);
    });

    test('get 2 errors', () async {
      List list = await repository.fetchAll(search: '');
      expect((list[1] as List).length, 2);
    });
  });
}
