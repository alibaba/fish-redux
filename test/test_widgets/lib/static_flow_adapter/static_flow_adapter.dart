import 'package:fish_redux/fish_redux.dart';
import '../test_base.dart';
import 'action.dart';
import 'component.dart';
import 'state.dart';

bool toDoListEffect(Action action, Context<ToDoList> ctx) {
  if (action.type == ToDoListAction.onAdd) {
    print('onAdd');
    ctx.dispatch(Action(ToDoListAction.add, payload: Todo.mock()));

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
    Todo toDo = state.list.firstWhere((toDo) => toDo?.id == action.payload.id);
    int index = state.list.indexOf(toDo);
    return state.clone()..list[index] = null;
  } else {
    return state.clone();
  }
}

class ToDoComponent0 extends ToDoComponent {}

class ToDoComponent1 extends ToDoComponent {}

class ToDoComponent2 extends ToDoComponent {}

class ToDoComponent3 extends ToDoComponent {}

final testAdapter = TestStaticFlowAdapter<ToDoList>(slots: [
  ConnOp<ToDoList, Todo>(
          get: (toDoList) => toDoList.list[0],
          set: (toDoList, toDo) => toDoList.list[0] = toDo) +
      ToDoComponent0(),
  ConnOp<ToDoList, Todo>(
          get: (toDoList) => toDoList.list[1],
          set: (toDoList, toDo) => toDoList.list[1] = toDo) +
      ToDoComponent1(),
  ConnOp<ToDoList, Todo>(
          get: (toDoList) => toDoList.list[2],
          set: (toDoList, toDo) => toDoList.list[2] = toDo) +
      ToDoComponent2(),
  ConnOp<ToDoList, Todo>(
          get: (toDoList) => toDoList.list[3],
          set: (toDoList, toDo) => toDoList.list[3] = toDo) +
      ToDoComponent3()
], reducer: toDoListReducer, effect: toDoListEffect);
