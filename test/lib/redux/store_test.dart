import 'dart:async';
import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';
import 'package:test/test.dart';

import '../instrument.dart';
import '../track.dart';

enum ToDoAction { add, remove, done }

class Todo {
  String id;
  String title;
  String desc;
  bool isDone = false;

  Todo();

  factory Todo.copy(Todo toDo) {
    return Todo()
      ..id = toDo.id
      ..title = toDo.title
      ..desc = toDo.desc
      ..isDone = toDo.isDone;
  }
}

class ToDoList {
  List<Todo> list = <Todo>[];

  ToDoList();

  factory ToDoList.copy(ToDoList toDoState) {
    return ToDoList()..list.addAll(toDoState.list);
  }
}

ToDoList toDoReducer(ToDoList state, Action action) {
  final ToDoList newState = ToDoList.copy(state);

  if (action.type == ToDoAction.add) {
    newState.list.add(action.payload);
  } else if (action.type == ToDoAction.remove) {
    newState.list.removeWhere((Todo toDo) => toDo.id == action.payload);
  } else if (action.type == ToDoAction.done) {
    newState.list
        .firstWhere((Todo toDo) => toDo.id == action.payload,
            orElse: () => null)
        ?.isDone = true;
  }

  return newState;
}

ToDoList defaultReducer(ToDoList state, Action action) => ToDoList.copy(state);

void main() {
  group('store', () {
    test('create without preloadedState', () {
      expect(() => createStore<ToDoList>(null, null), throwsArgumentError);
    });

    test('create without reducer', () {
      final Store<ToDoList> store = createStore<ToDoList>(ToDoList(), null);
      expect(store, isNotNull);
      expect(store, const TypeMatcher<Store<ToDoList>>());
      expect(store.getState(), isNotNull);
      expect(store.getState(), const TypeMatcher<ToDoList>());
    });

    test('create', () {
      final Store<ToDoList> store =
          createStore<ToDoList>(ToDoList(), toDoReducer);
      expect(store, isNotNull);
      expect(store, const TypeMatcher<Store<ToDoList>>());
      expect(store.getState(), isNotNull);
      expect(store.getState(), const TypeMatcher<ToDoList>());
    });

    test('dispatch & state', () {
      final Track track = Track();
      final Store<ToDoList> store = createStore<ToDoList>(
          ToDoList(),
          instrumentReducer(toDoReducer, pre: (ToDoList state, Action action) {
            if (action.type == ToDoAction.add) {
              track.append('onReduce_Add');
            } else if (action.type == ToDoAction.done) {
              track.append('onReduce_Done');
            } else if (action.type == ToDoAction.remove) {
              track.append('onReduce_Remove');
            }
          }));

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isEmpty);

      track.append('dispatch_Add');
      store.dispatch(Action(ToDoAction.add,
          payload: Todo()
            ..id = 'unique'
            ..title = 'test'
            ..desc = 'just test'));

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isNotEmpty);
      expect(store.getState().list.first, isNotNull);
      expect(store.getState().list.first.id, 'unique');
      expect(store.getState().list.first.title, 'test');
      expect(store.getState().list.first.desc, 'just test');
      expect(store.getState().list.first.isDone, isFalse);

      track.append('dispatch_Done');
      store.dispatch(const Action(ToDoAction.done, payload: 'unique'));

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isNotEmpty);
      expect(store.getState().list.first, isNotNull);
      expect(store.getState().list.first.id, 'unique');
      expect(store.getState().list.first.title, 'test');
      expect(store.getState().list.first.desc, 'just test');
      expect(store.getState().list.first.isDone, isTrue);

      track.append('dispatch_Remove');
      store.dispatch(const Action(ToDoAction.remove, payload: 'unique'));

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isEmpty);

      expect(
          track,
          Track.tags(<String>[
            'dispatch_Add',
            'onReduce_Add',
            'dispatch_Done',
            'onReduce_Done',
            'dispatch_Remove',
            'onReduce_Remove'
          ]));
    });

    test('subscribe', () {
      final Track track = Track();

      final Store<ToDoList> store = createStore<ToDoList>(
          ToDoList(),
          instrumentReducer(toDoReducer, pre: (ToDoList state, Action action) {
            if (action.type == ToDoAction.add) {
              track.append('onReduce_Add');
            } else if (action.type == ToDoAction.done) {
              track.append('onReduce_Done');
            } else if (action.type == ToDoAction.remove) {
              track.append('onReduce_Remove');
            } else {
              track.append('onReduce_Unkonw');
            }
          }));

      Todo firstToDo;
      store.subscribe(() {
        track.append('onSubscribe');
        firstToDo = store.getState().list.isEmpty
            ? null
            : Todo.copy(store.getState().list.first);
      });

      expect(firstToDo, isNull);

      track.append('dispatch_Add');
      store.dispatch(Action(ToDoAction.add,
          payload: Todo()
            ..id = 'unique'
            ..title = 'test'
            ..desc = 'just test'));

      expect(firstToDo, isNotNull);
      expect(firstToDo.id, 'unique');
      expect(firstToDo.title, 'test');
      expect(firstToDo.desc, 'just test');
      expect(firstToDo.isDone, isFalse);

      track.append('dispatch_Done');
      store.dispatch(const Action(ToDoAction.done, payload: 'unique'));

      expect(firstToDo, isNotNull);
      expect(firstToDo.id, 'unique');
      expect(firstToDo.title, 'test');
      expect(firstToDo.desc, 'just test');
      expect(firstToDo.isDone, isTrue);

      track.append('dispatch_Remove');
      store.dispatch(const Action(ToDoAction.remove, payload: 'unique'));

      expect(firstToDo, isNull);

      expect(
          track,
          Track.tags(<String>[
            'dispatch_Add',
            'onReduce_Add',
            'onSubscribe',
            'dispatch_Done',
            'onReduce_Done',
            'onSubscribe',
            'dispatch_Remove',
            'onReduce_Remove',
            'onSubscribe'
          ]));
    });

    test('unsubscribe', () {
      final Store<ToDoList> store =
          createStore<ToDoList>(ToDoList(), toDoReducer);

      Todo firstToDo;
      final VoidCallback unsubscribe = store.subscribe(() {
        firstToDo = store.getState().list.isEmpty
            ? null
            : Todo.copy(store.getState().list.first);
      });

      expect(firstToDo, isNull);

      store.dispatch(Action(ToDoAction.add,
          payload: Todo()
            ..id = 'unique'
            ..title = 'test'
            ..desc = 'just test'));

      expect(firstToDo, isNotNull);
      expect(firstToDo.id, 'unique');
      expect(firstToDo.title, 'test');
      expect(firstToDo.desc, 'just test');
      expect(firstToDo.isDone, isFalse);

      unsubscribe();

      store.dispatch(const Action(ToDoAction.remove, payload: 'unique'));

      expect(firstToDo, isNotNull);
      expect(firstToDo.id, 'unique');
      expect(firstToDo.title, 'test');
      expect(firstToDo.desc, 'just test');
      expect(firstToDo.isDone, isFalse);
    });

    test('observable', () {
      final Track track = Track();
      final Store<ToDoList> store = createStore<ToDoList>(
          ToDoList(),
          instrumentReducer(toDoReducer, pre: (ToDoList state, Action action) {
            if (action.type == ToDoAction.add) {
              track.append('onReduce_Add');
            } else if (action.type == ToDoAction.done) {
              track.append('onReduce_Done');
            } else if (action.type == ToDoAction.remove) {
              track.append('onReduce_Remove');
            } else {
              track.append('onReduce_Unkonw');
            }
          }));

      Todo firstToDo;
      store.observable().listen((ToDoList list) {
        track.append('observed');
        firstToDo = list.list.isEmpty ? null : Todo.copy(list.list.first);
      });

      expect(firstToDo, isNull);

      track.append('dispatch_Add');
      store.dispatch(Action(ToDoAction.add,
          payload: Todo()
            ..id = 'unique'
            ..title = 'test'
            ..desc = 'just test'));

      expect(firstToDo, isNotNull);
      expect(firstToDo.id, 'unique');
      expect(firstToDo.title, 'test');
      expect(firstToDo.desc, 'just test');
      expect(firstToDo.isDone, isFalse);

      track.append('dispatch_Done');
      store.dispatch(const Action(ToDoAction.done, payload: 'unique'));

      expect(firstToDo, isNotNull);
      expect(firstToDo.id, 'unique');
      expect(firstToDo.title, 'test');
      expect(firstToDo.desc, 'just test');
      expect(firstToDo.isDone, isTrue);

      track.append('dispatch_Remove');
      store.dispatch(const Action(ToDoAction.remove, payload: 'unique'));

      expect(firstToDo, isNull);
      expect(
          track,
          Track.tags(<String>[
            'dispatch_Add',
            'onReduce_Add',
            'observed',
            'dispatch_Done',
            'onReduce_Done',
            'observed',
            'dispatch_Remove',
            'onReduce_Remove',
            'observed'
          ]));
    });

    test('cancel observable', () {
      final Store<ToDoList> store =
          createStore<ToDoList>(ToDoList(), toDoReducer);

      Todo firstToDo;
      final StreamSubscription<ToDoList> subscription =
          store.observable().listen((ToDoList list) {
        firstToDo = list.list.isEmpty ? null : Todo.copy(list.list.first);
      });

      expect(firstToDo, isNull);

      store.dispatch(Action(ToDoAction.add,
          payload: Todo()
            ..id = 'unique'
            ..title = 'test'
            ..desc = 'just test'));

      expect(firstToDo, isNotNull);
      expect(firstToDo.id, 'unique');
      expect(firstToDo.title, 'test');
      expect(firstToDo.desc, 'just test');
      expect(firstToDo.isDone, isFalse);

      subscription.cancel();

      store.dispatch(const Action(ToDoAction.remove, payload: 'unique'));

      expect(firstToDo, isNotNull);
      expect(firstToDo.id, 'unique');
      expect(firstToDo.title, 'test');
      expect(firstToDo.desc, 'just test');
      expect(firstToDo.isDone, isFalse);
    });

    test('replaceReducer', () {
      final Store<ToDoList> store =
          createStore<ToDoList>(ToDoList(), toDoReducer);

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isEmpty);

      store.dispatch(Action(ToDoAction.add,
          payload: Todo()
            ..id = 'unique'
            ..title = 'test'
            ..desc = 'just test'));

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isNotEmpty);
      expect(store.getState().list.first, isNotNull);
      expect(store.getState().list.first.id, 'unique');
      expect(store.getState().list.first.title, 'test');
      expect(store.getState().list.first.desc, 'just test');
      expect(store.getState().list.first.isDone, isFalse);

      store.replaceReducer(defaultReducer);
      store.dispatch(const Action(ToDoAction.remove, payload: 'unique'));

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isNotEmpty);
      expect(store.getState().list.first, isNotNull);
      expect(store.getState().list.first.id, 'unique');
      expect(store.getState().list.first.title, 'test');
      expect(store.getState().list.first.desc, 'just test');
      expect(store.getState().list.first.isDone, isFalse);

      store.replaceReducer(toDoReducer);
      store.dispatch(const Action(ToDoAction.remove, payload: 'unique'));

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isEmpty);
    });

    test('applyMiddleware', () {
      Object lastAction;
      ToDoList lastState;

      final Track track = Track();

      final Middleware<ToDoList> toDoMiddleware = (
              {Dispatch dispatch, Get<ToDoList> getState}) =>
          (Dispatch next) => (Action action) {
                lastAction = action.type;
                lastState = ToDoList.copy(getState());
                next(action);
              };

      final Store<ToDoList> store = createStore<ToDoList>(
          ToDoList(),
          instrumentReducer(toDoReducer, pre: (ToDoList state, Action action) {
            if (action.type == ToDoAction.add) {
              track.append('onReduce_Add');
            } else if (action.type == ToDoAction.done) {
              track.append('onReduce_Done');
            } else if (action.type == ToDoAction.remove) {
              track.append('onReduce_Remove');
            } else {
              track.append('onReduce_Unkonw');
            }
          }),
          applyMiddleware(<Middleware<ToDoList>>[
            instrumentMiddleware(toDoMiddleware,
                pre: (Action action, Get<ToDoList> getReducer) {
              if (action.type == ToDoAction.add) {
                track.append('onMiddleware_Add');
              } else if (action.type == ToDoAction.done) {
                track.append('onMiddleware_Done');
              } else if (action.type == ToDoAction.remove) {
                track.append('onMiddleware_Remove');
              } else {
                track.append('onMiddleware_Unkonw');
              }
            })
          ]));

      store.subscribe(() {
        track.append('onSubscribe');
      });

      expect(store, isNotNull);
      expect(store, const TypeMatcher<Store<ToDoList>>());
      expect(store.getState(), isNotNull);
      expect(store.getState(), const TypeMatcher<ToDoList>());

      expect(store.getState(), isNotNull);
      expect(store.getState().list, isNotNull);
      expect(store.getState().list, isEmpty);

      expect(lastAction, isNull);
      expect(lastState, isNull);

      track.append('dispatch_Add');
      store.dispatch(Action(ToDoAction.add,
          payload: Todo()
            ..id = 'unique'
            ..title = 'test'
            ..desc = 'just test'));

      expect(lastAction, ToDoAction.add);
      expect(lastState, isNotNull);
      expect(lastState.list, isNotNull);
      expect(lastState.list, isEmpty);

      track.append('dispatch_Done');
      store.dispatch(const Action(ToDoAction.done, payload: 'unique'));

      expect(lastAction, ToDoAction.done);
      expect(lastState, isNotNull);
      expect(lastState.list, isNotNull);
      expect(lastState.list, isNotEmpty);
      expect(lastState.list.first, isNotNull);
      expect(lastState.list.first.id, 'unique');
      expect(lastState.list.first.title, 'test');
      expect(lastState.list.first.desc, 'just test');
      expect(lastState.list.first.isDone, isTrue);

      track.append('dispatch_Remove');
      store.dispatch(const Action(ToDoAction.remove, payload: 'unique'));

      expect(lastAction, ToDoAction.remove);
      expect(lastState, isNotNull);
      expect(lastState.list, isNotNull);
      expect(lastState.list, isNotEmpty);
      expect(lastState.list.first, isNotNull);
      expect(lastState.list.first.id, 'unique');
      expect(lastState.list.first.title, 'test');
      expect(lastState.list.first.desc, 'just test');
      expect(lastState.list.first.isDone, isTrue);

      expect(
          track,
          Track.tags(<String>[
            'dispatch_Add',
            'onMiddleware_Add',
            'onReduce_Add',
            'onSubscribe',
            'dispatch_Done',
            'onMiddleware_Done',
            'onReduce_Done',
            'onSubscribe',
            'dispatch_Remove',
            'onMiddleware_Remove',
            'onReduce_Remove',
            'onSubscribe'
          ]));
    });
  });
}
