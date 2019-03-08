import 'package:fish_redux/fish_redux.dart';

import 'action.dart';
import 'state.dart';
import 'todo_component/component.dart';

Reducer<PageState> buildReducer() {
  return asReducer(
    <Object, Reducer<PageState>>{PageAction.initToDos: _initToDosReducer},
  );
}

PageState _initToDosReducer(PageState state, Action action) {
  final List<ToDoState> toDos = action.payload ?? <ToDoState>[];
  final PageState newState = state.clone();
  newState.toDos = toDos;
  return newState;
}
