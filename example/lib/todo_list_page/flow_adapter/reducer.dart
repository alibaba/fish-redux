import 'package:fish_redux/fish_redux.dart';

import '../list_adapter/action.dart';
import '../state.dart';
import '../todo_component/action.dart' as todo_action;
import '../todo_component/component.dart';

Reducer<PageState> buildReducer() {
  return asReducer(<Object, Reducer<PageState>>{ToDoListAction.add: _add, todo_action.ToDoAction.remove: _remove})!;
}

PageState _add(PageState state, Action action) {
  final ToDoState toDo = action.payload;
  final List<ToDoState> list = state.toDos?.toList() ?? [];
  list.add(toDo);
  return state.clone()..toDos = list;
}

PageState _remove(PageState state, Action action) {
  final String unique = action.payload;
  return state.clone()
    ..toDos = (state.toDos?.toList() ?? []
      ..removeWhere((ToDoState state) => state.uniqueId == unique));
}
