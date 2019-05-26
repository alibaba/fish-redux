import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';

abstract class GlobalBaseState<T extends Cloneable<T>> implements Cloneable<T> {
  Color get themeColor;
  set themeColor(Color color);
}

class GlobalState implements GlobalBaseState<GlobalState> {
  @override
  Color themeColor;

  @override
  GlobalState clone() {
    return GlobalState();
  }
}
