import 'package:bloc/bloc.dart';
import 'package:check_prices/BLoC/textfield/textfield_state.dart';

class TextFieldCubit extends Cubit<TextFieldState> {
  TextFieldCubit() : super(Initial());

  void clear() {
    emit(Cleared());
    emit(Initial());
  }

  void reload() {
    emit(Reloaded());
    emit(Initial());
  }
}
