import 'package:fish_redux/fish_redux.dart';
// import 'package:uuid/uuid.dart';

class ToDoState implements Cloneable<ToDoState> {
  String uniqueId;
  String title;
  String desc;
  bool isDone;

  static int _seed = 202103051044;

  ToDoState({this.uniqueId, this.title, this.desc, this.isDone = false}) {
    uniqueId ??= '${_seed++}';
  }

  @override
  ToDoState clone() {
    return ToDoState()
      ..uniqueId = uniqueId
      ..title = title
      ..desc = desc
      ..isDone = isDone;
  }

  @override
  String toString() {
    return 'ToDoState{uniqueId: $uniqueId, title: $title, desc: $desc, isDone: $isDone}';
  }
}
