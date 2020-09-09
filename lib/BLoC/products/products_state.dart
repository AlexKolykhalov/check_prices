part of 'products_bloc.dart';

@immutable
abstract class ProductsState extends Equatable {
  Map<String, List<dynamic>> get data => {'products': [], 'errors': []};

  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoadInProgress extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final Map<String, List<dynamic>> data;

  ProductsLoaded({@required this.data});

  @override
  List<Object> get props => [data];
}
