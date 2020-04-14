import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import 'action.dart';
import 'state.dart';

Widget toDoView(Todo toDo, Dispatch dispatch, ViewService viewService) {
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
                  dispatch(
                      Action(ToDoListAction.remove, payload: toDo.clone()));
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
                  dispatch(Action(ToDoAction.onEdit, payload: toDo.clone()));
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
              dispatch(Action(ToDoAction.markDone, payload: toDo.clone()));
            }
          },
          onLongPress: () {
            print('dispatch broadcast');
            dispatch(Action(ToDoAction.onBroadcast));
          },
        )
      ],
    ),
  );
}

bool toDoEffect(Action action, Context<Todo> ctx) {
  if (action.type == ToDoAction.onEdit) {
    print('onEdit');

    Todo toDo = ctx.state.clone();
    toDo.desc = '${toDo.desc}-effect';

    ctx.dispatch(Action(ToDoAction.edit, payload: toDo));
    return true;
  } else if (action.type == ToDoAction.onBroadcast) {
    ctx.broadcastEffect(Action(ToDoAction.broadcast));
    return true;
  } else if (action.type == Lifecycle.initState) {
    print('!!! initState ${ctx.state}');
    return true;
  } else if (action.type == Lifecycle.dispose) {
    print('!!! dispose ${ctx.state}');
    return true;
  }

  return false;
}

dynamic toDoEffectAsync(Action action, Context<Todo> ctx) {
  if (action.type == ToDoAction.onEdit) {
    return Future.delayed(Duration(seconds: 1), () => toDoEffect(action, ctx));
  }

  return null;
}

Dispatch toDoHigherEffect(Context<Todo> ctx) =>
    (Action action) => toDoEffect(action, ctx);

Todo toDoReducer(Todo state, Action action) {
  if (!(action.payload is Todo) || state.id != action.payload.id) return state;

  print('onReduce:${action.type}');

  if (action.type == ToDoAction.markDone) {
    return state.clone()..isDone = true;
  } else if (action.type == ToDoAction.edit) {
    return state.clone()..desc = action.payload.desc;
  } else {
    return state.clone();
  }
}

bool shouldUpdate(Todo old, Todo now) => old != now;

bool reducerFilter(Todo toDo, Action action) {
  return action.type == ToDoAction.edit || action.type == ToDoAction.markDone;
}

class ToDoComponent extends Component<Todo> {
  ToDoComponent()
      : super(
            view: toDoView,
            effect: toDoEffect,
            reducer: toDoReducer,
            shouldUpdate: shouldUpdate,
            filter: reducerFilter);
}

class ComponentWrapper extends StatelessWidget {
  final Widget child;

  ComponentWrapper(this.child);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
