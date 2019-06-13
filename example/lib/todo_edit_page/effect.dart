import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../global_store/action.dart';
import '../global_store/store.dart';
import '../todo_list_page/todo_component/component.dart';
import 'action.dart';
import 'state.dart';

Effect<TodoEditState> buildEffect() {
  return combineEffects(<Object, Effect<TodoEditState>>{
    Lifecycle.initState: _init,
    ToDoEditAction.onDone: _onDone,
    ToDoEditAction.onChangeTheme: _onChangeTheme,
  });
}

void _init(Action action, Context<TodoEditState> ctx) {
  ctx.state.nameEditController.addListener(() {
    ctx.dispatch(
        ToDoEditActionCreator.update(ctx.state.nameEditController.text, null));
  });

  ctx.state.descEditController.addListener(() {
    ctx.dispatch(
        ToDoEditActionCreator.update(null, ctx.state.descEditController.text));
  });
}

void _onDone(Action action, Context<TodoEditState> ctx) {
  Navigator.of(ctx.context).pop<ToDoState>(ctx.state.toDo);
}

void _onChangeTheme(Action action, Context<TodoEditState> ctx) {
  //change global data
  GlobalStore.store.dispatch(GlobalActionCreator.onchangeThemeColor());
}
