import 'package:fish_redux/fish_redux.dart';

enum ToDoEditAction { update, onDone, onChangeTheme }

class ToDoEditActionCreator {
  static Action update(String name, String desc, String themeidx) {
    return Action(
      ToDoEditAction.update,
      payload: <String, String>{
        'name': name,
        'desc': desc,
        'themeidx': themeidx
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
