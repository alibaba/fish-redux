import 'package:fish_redux/fish_redux.dart';

import '../state.dart';
import '../todo_component/component.dart';

class ToDoConnector
    extends ConnOp<PageState, ToDoState> {

      ToDoConnector({this.index});

      final int index;

  @override
  ToDoState get(PageState state) {
    if (index >= state.toDos.length) {
      return null;
    }
    return state.toDos[index];
  }

  @override
  void set(PageState state, ToDoState subState) {
    state.toDos[index] = subState;
  }
}