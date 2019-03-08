import 'package:fish_redux/fish_redux.dart';
import 'todo_component/component.dart';

enum PageAction { initToDos, onAdd }

class PageActionCreator {
  static Action initToDosAction(List<ToDoState> toDos) {
    return Action(PageAction.initToDos, payload: toDos);
  }

  static Action onAddAction() {
    return const Action(PageAction.onAdd);
  }
}
