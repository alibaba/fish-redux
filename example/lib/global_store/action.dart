import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';

enum GlobalAction { changeThemeColor }

class GlobalActionCreator {
  static Action onchangeThemeColor(Color color) {
    return Action(GlobalAction.changeThemeColor, payload: color);
  }
}
