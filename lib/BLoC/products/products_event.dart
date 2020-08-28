part of 'products_bloc.dart';

@immutable
abstract class ProductsEvent {}

class ProductsFetched extends ProductsEvent {
  ProductsFetched({this.search});

  final String search;
}
