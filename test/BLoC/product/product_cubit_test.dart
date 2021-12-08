import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'package:check_prices/BLoC/product/product_cubit.dart';
import 'package:check_prices/BLoC/product/product_state.dart';

main() {
  late ProductCubit productCubit;

  setUp(() {
    productCubit = ProductCubit();
  });

  tearDown(() {
    productCubit.close();
  });

  test('initial state as [Initial]', () {
    expect(productCubit.state.runtimeType, Initial);
  });

  blocTest<ProductCubit, ProductState>(
    'emits [Loading, Loaded] when load() is called',
    build: () => productCubit,
    act: (cubit) => cubit.load(''),
    wait: Duration(seconds: 1),
    expect: () => [
      isA<Loading>(),
      isA<Loaded>(),
    ],
  );
}
