import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'package:check_prices/BLoC/textfield/textfield_cubit.dart';
import 'package:check_prices/BLoC/textfield/textfield_state.dart';

main() {
  late TextFieldCubit textFieldCubit;

  setUp(() {
    textFieldCubit = TextFieldCubit();
  });

  tearDown(() {
    textFieldCubit.close();
  });

  test('initial state as [Initial]', () {
    expect(textFieldCubit.state.runtimeType, Initial);
  });

  blocTest<TextFieldCubit, TextFieldState>(
    'emits [Cleared, Initial] when clear() is called',
    build: () => textFieldCubit,
    act: (cubit) => cubit.clear(),
    wait: Duration(seconds: 1),
    expect: () => [isA<Cleared>(), isA<Initial>()],
  );

  blocTest<TextFieldCubit, TextFieldState>(
    'emits [Reloaded, Initial] when reload() is called',
    build: () => textFieldCubit,
    act: (cubit) => cubit.reload(),
    wait: Duration(seconds: 1),
    expect: () => [isA<Reloaded>(), isA<Initial>()],
  );
}
