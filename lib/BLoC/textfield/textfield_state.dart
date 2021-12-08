import 'package:equatable/equatable.dart';

class TextFieldState extends Equatable {
  @override
  List<Object?> get props => [];
}

class Initial extends TextFieldState {}

class Cleared extends TextFieldState {}

class Reloaded extends TextFieldState {}
