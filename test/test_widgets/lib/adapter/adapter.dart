import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import 'action.dart';
import 'state.dart';

Widget toDoView(
  ToDo toDo,
  Dispatch dispatch,
  ViewService viewService,
) {
  return Container(
    margin: const EdgeInsets.all(8.0),
    color: Colors.grey,
    child: Row(
      children: <Widget>[
        Expanded(
            child: Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  key: ValueKey('remove-${toDo.id}'),
                  padding: const EdgeInsets.all(8.0),
                  height: 28.0,
                  color: Colors.yellow,
                  child: Text(
                    toDo.title,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  alignment: AlignmentDirectional.centerStart,
                ),
                onTap: () {
                  print('dispatch remove');
                  dispatch(Action(ToDoListAction.remove, payload: toDo));
                },
              ),
              GestureDetector(
                child: Container(
                  key: ValueKey('edit-${toDo.id}'),
                  padding: const EdgeInsets.all(8.0),
                  height: 60.0,
                  color: Colors.grey,
                  child: Text(toDo.desc, style: TextStyle(fontSize: 14.0)),
                  alignment: AlignmentDirectional.centerStart,
                ),
                onTap: () {
                  print('dispatch onEdit');
                  dispatch(Action(ToDoListAction.onEdit, payload: toDo));
                },
              )
            ],
          ),
        )),
        GestureDetector(
            child: Container(
              key: ValueKey('mark-${toDo.id}'),
              color: toDo.isDone ? Colors.green : Colors.red,
              width: 88.0,
              height: 88.0,
              child: Text(toDo.isDone ? 'done' : 'mark\ndone'),
              alignment: AlignmentDirectional.center,
            ),
            onTap: () {
              if (!toDo.isDone) {
                print('dispatch markDone');
                dispatch(Action(ToDoListAction.markDone, payload: toDo));
              }
            },
            onLongPress: () {
              print('dispatch Add');
              dispatch(Action(ToDoListAction.onAdd, payload: toDo));
            })
      ],
    ),
  );
}

bool toDoListEffect(Action action, Context<ToDoList> ctx) {
  if (action.type == ToDoListAction.onAdd) {
    print('onAdd');
    ctx.dispatch(Action(ToDoListAction.add, payload: ToDo.mock()));

    return true;
  } else if (action.type == ToDoListAction.onEdit) {
    print('onEdit');
    assert(action.payload is ToDo);

    ToDo toDo = ctx.state.list
        .firstWhere((i) => i.id == action.payload.id, orElse: () => null)
        .clone();
    toDo.desc = '${toDo.desc}-effect';
    ctx.dispatch(Action(ToDoListAction.edit, payload: toDo));
    return true;
  }

  return false;
}

dynamic toDoListEffectAsync(Action action, Context<ToDoList> ctx) {
  if (action.type == ToDoListAction.onAdd ||
      action.type == ToDoListAction.onEdit ||
      action.type == ToDoListAction.onKnowException ||
      action.type == ToDoListAction.onUnKnowException) {
    return Future.delayed(
        Duration(seconds: 1), () => toDoListEffect(action, ctx));
  }

  return null;
}

OnAction toDoListHigherEffect(Context<ToDoList> ctx) =>
    (Action action) => toDoListEffect(action, ctx);

ToDoList toDoListReducer(ToDoList state, Action action) {
  print('onReduce:${action.type}');
  if (!(action.payload is ToDo)) return state;

  ToDo item = action.payload as ToDo;

  if (action.type == ToDoListAction.add) {
    return state.clone()..list.add(item);
  } else if (action.type == ToDoListAction.markDone) {
    return state.clone()
      ..list
          .firstWhere((toDo) => toDo.id == item.id, orElse: () => null)
          ?.isDone = true;
  } else if (action.type == ToDoListAction.remove) {
    return state.clone()..list.removeWhere((toDo) => toDo.id == item.id);
  } else if (action.type == ToDoListAction.edit) {
    ToDo toDo = state.list.firstWhere((toDo) => toDo.id == item.id);
    int index = state.list.indexOf(toDo);
    toDo = toDo.clone()..desc = item.desc;
    return state.clone()..list[index] = toDo;
  } else {
    return state;
  }
}

ListAdapter toDoListAdapter(
  ToDoList state,
  Dispatch dispatch,
  ViewService viewService,
) {
  return ListAdapter((context, index) {
    ToDo toDo = state.list[index];

    return toDoView(toDo, dispatch, viewService);
  }, state.list.length);
}
