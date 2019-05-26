import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';

class GlobalState implements Cloneable<GlobalState> {
  Color themeColor;
  @override
  GlobalState clone() {
    return GlobalState();
  }
}
