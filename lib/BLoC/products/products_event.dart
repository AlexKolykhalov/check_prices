part of 'products_bloc.dart';

@immutable
abstract class ProductsEvent extends Equatable {}

class ProductsFetched extends ProductsEvent {
  ProductsFetched({@required this.search});

  final String search;

  @override
  List<Object> get props => [search];
}
