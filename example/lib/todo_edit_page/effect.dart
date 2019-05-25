import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:sample/global_store/action.dart';
import 'package:sample/global_store/global_store.dart';

import '../todo_list_page/todo_component/component.dart';
import 'action.dart';
import 'state.dart';

Effect<TodoEditState> buildEffect() {
  return combineEffects(<Object, Effect<TodoEditState>>{
    Lifecycle.initState: _init,
    ToDoEditAction.done: _onDone,
    ToDoEditAction.changeTheme : _onchangeTheme,
  });
}

void _init(Action action, Context<TodoEditState> ctx) {
  ctx.state.nameEditController.addListener(() {
    ctx.dispatch(
        ToDoEditActionCreator.update(ctx.state.nameEditController.text, null, null));
  });

  ctx.state.descEditController.addListener(() {
    ctx.dispatch(
        ToDoEditActionCreator.update(null, ctx.state.descEditController.text, null));
  });
}

void _onDone(Action action, Context<TodoEditState> ctx) {
  Navigator.of(ctx.context).pop<ToDoState>(ctx.state.toDo);
}

void _onchangeTheme(Action action, Context<TodoEditState> ctx) {
  ctx.state.themeIdx++;
  if(ctx.state.themeIdx >= ctx.state.themeColorSlots.length)
  {
    ctx.state.themeIdx = 0;
  }
  //change global data
  GlobalStore.store.dispatch(GlobalActionCreator.onchangeThemeColor(ctx.state.themeColorSlots[ctx.state.themeIdx]));
  //notify todo edit page update data
  ToDoEditActionCreator.update(null, null, ctx.state.themeIdx.toString());
}
