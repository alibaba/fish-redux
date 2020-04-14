import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import '../test_base.dart';
import 'action.dart';
import 'component.dart';
import 'state.dart';

Widget toDoListView(
  ToDoList state,
  Dispatch dispatch,
  ViewService viewService,
) {
  print('build toDoListView');
  return Column(
    children: <Widget>[
      Expanded(
          child: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return viewService.buildComponent('toDo0');
          } else if (index == 1) {
            return viewService.buildComponent('toDo1');
          } else if (index == 2) {
            return viewService.buildComponent('toDo2');
          } else if (index == 3) {
            return viewService.buildComponent('toDo3');
          } else {
            Todo toDo = state.list[index];
            return Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              color: Colors.grey,
              child: Text(toDo.desc),
              alignment: AlignmentDirectional.center,
            );
          }
        },
        itemCount: state.list.length,
      )),
      Row(
        children: <Widget>[
          Expanded(
              child: GestureDetector(
            child: Container(
              key: ValueKey('Add'),
              height: 68.0,
              color: Colors.green,
              alignment: AlignmentDirectional.center,
              child: Text('Add'),
            ),
            onTap: () {
              print('dispatch Add');
              dispatch(Action(ToDoListAction.onAdd));
            },
          )),
        ],
      )
    ],
  );
}

bool toDoListEffect(Action action, Context<ToDoList> ctx) {
  if (action.type == ToDoListAction.onAdd) {
    print('onAdd');
    ctx.dispatch(Action(ToDoListAction.add, payload: Todo.mock()));
    return true;
  } else if (action.type == ToDoListAction.onBroadcast) {
    ctx.broadcastEffect(Action(ToDoListAction.broadcast));
    return true;
  }

  return false;
}

dynamic toDoListEffectAsync(Action action, Context<ToDoList> ctx) {
  if (action.type == ToDoListAction.onAdd) {
    return Future.delayed(
        Duration(seconds: 1), () => toDoListEffect(action, ctx));
  }

  return null;
}

Dispatch toDoListHigherEffect(Context<ToDoList> ctx) =>
    (Action action) => toDoListEffect(action, ctx);

ToDoList toDoListReducer(ToDoList state, Action action) {
  print('onReduce:${action.type}');
  if (!(action.payload is Todo)) return state;

  if (action.type == ToDoListAction.add) {
    return state.clone()..list.add(action.payload);
  } else if (action.type == ToDoListAction.remove) {
    Todo toDo = state.list.firstWhere((toDo) => toDo.id == action.payload.id);
    int index = state.list.indexOf(toDo);
    toDo = toDo.clone()..desc = 'removed';
    return state.clone()..list[index] = toDo;
  } else {
    return state.clone();
  }
}

const Map pageInitParams = <String, dynamic>{
  'list': [
    <String, dynamic>{
      'id': '0',
      'title': 'title-0',
      'desc': 'desc-0',
      'isDone': false
    },
    <String, dynamic>{
      'id': '1',
      'title': 'title-1',
      'desc': 'desc-1',
      'isDone': false
    },
    <String, dynamic>{
      'id': '2',
      'title': 'title-2',
      'desc': 'desc-2',
      'isDone': false
    },
    <String, dynamic>{
      'id': '3',
      'title': 'title-3',
      'desc': 'desc-3',
      'isDone': true
    }
  ]
};

ToDoList initState(Map map) => ToDoList.fromMap(map);

class ToDoComponent0 extends ToDoComponent {}

class ToDoComponent1 extends ToDoComponent {}

class ToDoComponent2 extends ToDoComponent {}

class ToDoComponent3 extends ToDoComponent {}

final toDoListDependencies = Dependencies<ToDoList>(slots: {
  'toDo0': ConnOp<ToDoList, Todo>(
          get: (toDoList) => toDoList.list[0],
          set: (toDoList, toDo) => toDoList.list[0] = toDo) +
      ToDoComponent0(),
  'toDo1': ConnOp<ToDoList, Todo>(
          get: (toDoList) => toDoList.list[1],
          set: (toDoList, toDo) => toDoList.list[1] = toDo) +
      ToDoComponent1(),
  'toDo2': ConnOp<ToDoList, Todo>(
          get: (toDoList) => toDoList.list[2],
          set: (toDoList, toDo) => toDoList.list[2] = toDo) +
      ToDoComponent2(),
  'toDo3': ConnOp<ToDoList, Todo>(
          get: (toDoList) => toDoList.list[3],
          set: (toDoList, toDo) => toDoList.list[3] = toDo) +
      ToDoComponent3(),
});

Widget createComponentWidget(BuildContext context) {
  return TestPage<ToDoList, Map>(
          initState: initState,
          view: toDoListView,
          reducer: toDoListReducer,
          effect: toDoListEffect,
          dependencies: toDoListDependencies)
      .buildPage(pageInitParams);
}
