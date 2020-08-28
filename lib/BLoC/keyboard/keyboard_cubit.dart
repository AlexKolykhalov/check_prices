import 'package:bloc/bloc.dart';

class KeyboardCubit extends Cubit<bool> {
  KeyboardCubit() : super(false);

  void readOnlyKeyboard(value) => emit(value);
}
