import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';

import 'action.dart';
import 'state.dart';

Reducer<GlobalState> buildReducer() {
  return asReducer(
    <Object, Reducer<GlobalState>>{
      GlobalAction.action: _onAction,
      GlobalAction.changeThemeColor: _onchangeThemeColor,
    },
  );
}

GlobalState _onAction(GlobalState state, Action action) {
  final GlobalState newState = state.clone();
  return newState;
}

GlobalState _onchangeThemeColor(GlobalState state, Action action) {
  final GlobalState newState = state.clone();
  newState.themeColor = action.payload as Color;
  return newState;
}
