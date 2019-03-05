import 'package:fish_redux/fish_redux.dart';

class ToDo implements Cloneable<ToDo> {
  String id;
  String title;
  String desc;
  bool isDone = false;

  ToDo();

  factory ToDo.mock() => ToDo()
    ..id = 'id-mock'
    ..title = 'title-mock'
    ..desc = 'desc-mock'
    ..isDone = false;

  @override
  ToDo clone() => ToDo()
    ..id = this.id
    ..title = this.title
    ..desc = this.desc
    ..isDone = this.isDone;

  factory ToDo.fromMap(Map map) {
    return ToDo()
      ..id = map['id'] ?? 'uniq'
      ..title = map['title'] ?? ''
      ..desc = map['desc'] ?? ''
      ..isDone = map['isDone'] ?? false;
  }

  @override
  bool operator ==(dynamic other) {
    if (!(other is ToDo)) return false;

    return id == other.id &&
        title == other.title &&
        desc == other.desc &&
        isDone == other.isDone;
  }

  @override
  String toString() {
    return 'ToDo{id: $id, title: $title, desc: $desc, isDone: $isDone}';
  }
}

class ToDoList implements Cloneable<ToDoList> {
  List<ToDo> list = <ToDo>[];

  ToDoList();

  @override
  ToDoList clone() => ToDoList()..list.addAll(this.list);

  factory ToDoList.fromMap(Map map) {
    return ToDoList()
      ..list.addAll(
          map['list']?.map<ToDo>((Map map) => ToDo.fromMap(map))?.toList());
  }

  @override
  bool operator ==(dynamic other) {
    if (!(other is ToDoList)) return false;

    if (list.length != other.list.length) return false;

    for (int index = 0; index < list.length; index++) {
      if (list[index] != other.list[index]) return false;
    }

    return true;
  }

  @override
  String toString() {
    return '{list: $list}';
  }

}
