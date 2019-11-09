import 'package:fish_redux/fish_redux.dart';

import '../test_base.dart';
import 'action.dart';
import 'component.dart';
import 'state.dart';

bool toDoListEffect(Action action, Context<ToDoList> ctx) {
  if (action.type == ToDoListAction.onAdd) {
    print('adapter onAdd');
    ctx.dispatch(Action(ToDoListAction.add, payload: Todo.mock()));
    return true;
  }

  return false;
}

ToDoList toDoListReducer(ToDoList state, Action action) {
  print('onReduce:${action.type}');
  if (!(action.payload is Todo)) return state;

  if (action.type == ToDoListAction.add) {
    return state.clone()..list.add(action.payload);
  } else if (action.type == ToDoListAction.remove) {
    return state.clone()
      ..list.removeWhere((Todo toDo) => toDo.id == action.payload.id);
  } else {
    return state.clone();
  }
}

final TestSourceFlowAdapter<ToDoList> testAdapter =
    TestSourceFlowAdapter<ToDoList>(
  pool: <String, ToDoComponent>{'toDo': ToDoComponent()},
  reducer: toDoListReducer,
  effect: toDoListEffect,
);
