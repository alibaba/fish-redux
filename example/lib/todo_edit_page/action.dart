import 'package:fish_redux/fish_redux.dart';

enum ToDoEditAction { update, onDone, onChangeTheme }

class ToDoEditActionCreator {
  static Action update(String name, String desc) {
    return Action(
      ToDoEditAction.update,
      payload: <String, String>{
        'name': name,
        'desc': desc,
      },
    );
  }

  static Action onDone() {
    return const Action(ToDoEditAction.onDone);
  }

  static Action onChangeTheme() {
    return const Action(ToDoEditAction.onChangeTheme);
  }
}
