import 'package:fish_redux/src/redux_connector/generator.dart';

abstract class ExtraState{
  String get identifier => 'identifier ${generator()()}';
}