import 'package:fish_redux/fish_redux.dart';

enum ToDoEditAction { update, done, changeTheme }

class ToDoEditActionCreator {
  static Action update(String name, String desc, String themeidx) {
    return Action(
      ToDoEditAction.update,
      payload: <String, String>{'name': name, 'desc': desc, 'themeidx' : themeidx},
    );
  }

  static Action done() {
    return const Action(ToDoEditAction.done);
  }

  static Action changeTheme(){
    return Action(ToDoEditAction.changeTheme);
  }
}
