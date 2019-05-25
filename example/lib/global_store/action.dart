import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';

//TODO replace with your own action
enum GlobalAction { action, changeThemeColor}

class GlobalActionCreator {
  static Action onAction() {
    return const Action(GlobalAction.action);
  }

  static Action onchangeThemeColor(Color color){
    return Action(GlobalAction.changeThemeColor, payload: color);
  }
}
