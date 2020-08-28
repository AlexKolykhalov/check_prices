import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'package:check_prices/repo/repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({this.repository}) : super(ProductsInitial());
  final Repository repository;
  Map<String, List<dynamic>> data;

  @override
  Stream<Transition<ProductsEvent, ProductsState>> transformEvents(
      Stream<ProductsEvent> events, transitionFn) {
    return events
        .debounceTime(const Duration(seconds: 1))
        .switchMap(transitionFn);
  }

  @override
  Stream<ProductsState> mapEventToState(
    ProductsEvent event,
  ) async* {
    if (event is ProductsFetched) {
      yield ProductsLoadInProgress();
      data = await repository.fetchAll(search: event.search);
      yield ProductsLoaded(data: data);
    }
  }
}
