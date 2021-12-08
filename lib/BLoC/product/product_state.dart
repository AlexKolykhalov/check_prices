import 'package:check_prices/models/models.dart';
import 'package:equatable/equatable.dart';

class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class Initial extends ProductState {}

class Loading extends ProductState {}

class Loaded extends ProductState {
  Loaded({
    this.products = const <Product>[],
    this.errors = const [],
  });

  final List<Product> products;
  final List<String> errors;

  @override
  List<Object?> get props => [products, errors];
}
