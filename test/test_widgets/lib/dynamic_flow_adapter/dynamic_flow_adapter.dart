import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'state.dart';
import 'action.dart';
import 'component.dart';
import '../test_base.dart';

bool toDoListEffect(Action action, Context<ToDoList> ctx) {
  if (action.type == ToDoListAction.onAdd) {
    print('adapter onAdd');
    ctx.dispatch(Action(ToDoListAction.add, payload: ToDo.mock()));
    return true;
  }

  return false;
}

ToDoList toDoListReducer(ToDoList state, Action action) {
  print('onReduce:${action.type}');
  if (!(action.payload is ToDo)) return state;

  if (action.type == ToDoListAction.add) {
    return state.clone()..list.add(action.payload);
  } else if (action.type == ToDoListAction.remove) {
    return state.clone()
      ..list.removeWhere((ToDo toDo) => toDo.id == action.payload.id);
  } else {
    return state.clone();
  }
}

final testAdapter = TestDynamicFlowAdapter<ToDoList>(
    pool: <String, ToDoComponent>{'toDo': ToDoComponent()},
    connector: Connector<ToDoList, List<ItemBean>>(
        get: (ToDoList toDoList) => toDoList.list
            .map<ItemBean>((ToDo toDo) => ItemBean('toDo', toDo))
            .toList(),
        set: (ToDoList toDoList, List<ItemBean> beans) {
          toDoList.list.clear();
          toDoList.list
              .addAll(beans.map<ToDo>((ItemBean bean) => bean.data).toList());
        }),
    reducer: toDoListReducer,
    effect: toDoListEffect);
