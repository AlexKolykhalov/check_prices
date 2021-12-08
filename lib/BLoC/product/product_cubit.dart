import 'package:check_prices/BLoC/product/product_state.dart';
import 'package:check_prices/repo/data_providers.dart';
import 'package:check_prices/repo/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(Initial());

  late List _fetchData;
  final Repository _repository = Repository(dataProvider: DataProvider());

  void load(String search) async {
    emit(Loading());
    _fetchData = await _repository.fetchAll(search: search);
    emit(Loaded(products: _fetchData[0], errors: _fetchData[1]));
  }
}
