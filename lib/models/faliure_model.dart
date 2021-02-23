import 'package:equatable/equatable.dart';

class Faliure extends Equatable{
  final String message;

  const Faliure({this.message=''});

  @override
  List<Object> get props=>[message];
}