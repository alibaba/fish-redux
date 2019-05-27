import 'package:fish_redux/fish_redux.dart';

import 'action.dart';
import 'state.dart';

Reducer<TodoEditState> buildReducer() {
  return asReducer<TodoEditState>(
      <Object, Reducer<TodoEditState>>{ToDoEditAction.update: _update});
}

TodoEditState _update(TodoEditState state, Action action) {
  final Map<String, String> update = action.payload ?? <String, String>{};
  final TodoEditState newState = state.clone();
  newState.toDo.title = update['name'] ?? newState.toDo.title;
  newState.toDo.desc = update['desc'] ?? newState.toDo.desc;
  return newState;
}
