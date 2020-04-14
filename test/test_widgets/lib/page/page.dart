import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import '../test_base.dart';
import 'action.dart';
import 'exception.dart';
import 'state.dart';

Widget toDoView(Todo toDo, BuildContext context, Dispatch dispatch) {
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
                onLongPress: () {
                  print('dispatch middlewareEdit');
                  dispatch(
                      Action(ToDoListAction.middlewareEdit, payload: toDo));
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
        )
      ],
    ),
  );
}

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
          Todo toDo = state.list[index];
          return toDoView(toDo, context, dispatch);
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
          Expanded(
              child: GestureDetector(
                  child: Container(
                    key: ValueKey('Error'),
                    height: 68.0,
                    color: Colors.red,
                    alignment: AlignmentDirectional.center,
                    child: Text('Error'),
                  ),
                  onTap: () {
                    print('dispatch KnowException');
                    dispatch(Action(ToDoListAction.onKnowException));
                  },
                  onLongPress: () {
                    print('dispatch UnKnowException');
                    dispatch(Action(ToDoListAction.onUnKnowException));
                  }))
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
  } else if (action.type == ToDoListAction.onEdit) {
    print('onEdit');
    assert(action.payload is Todo);

    Todo toDo = ctx.state.list
        .firstWhere((i) => i.id == action.payload.id, orElse: () => null);

    assert(toDo != null);

    toDo = toDo.clone();
    toDo.desc = '${toDo.desc}-effect';

    ctx.dispatch(Action(ToDoListAction.edit, payload: toDo));
    return true;
  } else if (action.type == ToDoListAction.onKnowException) {
    throw KnowException();
  } else if (action.type == ToDoListAction.onUnKnowException) {
    throw UnKnowException();
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

ToDoList toDoListReducer(ToDoList state, Action action) {
  print('onReduce:${action.type}');
  if (!(action.payload is Todo)) return state;

  Todo item = action.payload as Todo;

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
    return state.clone()
      ..list
          .firstWhere((toDo) => toDo.id == item.id, orElse: () => null)
          ?.desc = item.desc;
  } else {
    return state;
  }
}

bool forbidRefreshUI(ToDoList old, ToDoList now) {
  return false;
}

bool toDoListErrorHandler(Exception exception, Context<ToDoList> ctx) {
  print('onErr:$exception');
  if (exception is KnowException) {
    return true;
  }

  return false;
}

Composable<Dispatch> toDoListMiddleware({
  Dispatch dispatch,
  Get<ToDoList> getState,
}) =>
    (Dispatch next) => (Action action) {
          if (action.type == ToDoListAction.middlewareEdit) {
            assert(action.payload is Todo);

            Todo toDo = getState().list.firstWhere(
                (i) => i.id == action.payload.id,
                orElse: () => null);

            assert(toDo != null);

            toDo = toDo.clone();
            toDo.desc = '${toDo.desc}-middleware';

            dispatch(Action(ToDoListAction.edit, payload: toDo));
          }

          next(action);
        };

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

class PageWrapper extends StatelessWidget {
  final Widget child;

  PageWrapper(this.child);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

Widget createPageWidget(BuildContext context) {
  return TestPage<ToDoList, Map>(
      initState: initState,
      view: toDoListView,
      reducer: toDoListReducer,
      effect: toDoListEffectAsync,
//      shouldUpdate: forbidRefreshWhenAddOrRemove,
//      onError: toDoListErrorHandler,
      middleware: [toDoListMiddleware]).buildPage(pageInitParams);
}
