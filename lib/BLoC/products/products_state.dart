part of 'products_bloc.dart';

@immutable
abstract class ProductsState {
  Map<String, List<dynamic>> get data => {'products': [], 'errors': []};
}

class ProductsInitial extends ProductsState {}

class ProductsLoadInProgress extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final Map<String, List<dynamic>> data;

  ProductsLoaded({this.data});
}
