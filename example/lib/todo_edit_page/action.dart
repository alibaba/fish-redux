import 'package:fish_redux/fish_redux.dart';

enum ToDoEditAction { update, done }

class ToDoEditActionCreator {
  static Action update(String name, String desc) {
    return Action(
      ToDoEditAction.update,
      payload: <String, String>{'name': name, 'desc': desc},
    );
  }

  static Action done() {
    return const Action(ToDoEditAction.done);
  }
}
