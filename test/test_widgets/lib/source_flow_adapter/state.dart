import 'package:fish_redux/fish_redux.dart';

class Todo implements Cloneable<Todo> {
  String id;
  String title;
  String desc;
  bool isDone = false;

  Todo();

  factory Todo.mock() => Todo()
    ..id = 'id-mock'
    ..title = 'title-mock'
    ..desc = 'desc-mock'
    ..isDone = false;

  @override
  Todo clone() => Todo()
    ..id = this.id
    ..title = this.title
    ..desc = this.desc
    ..isDone = this.isDone;

  factory Todo.fromMap(Map map) {
    return Todo()
      ..id = map['id'] ?? 'uniq'
      ..title = map['title'] ?? ''
      ..desc = map['desc'] ?? ''
      ..isDone = map['isDone'] ?? false;
  }

  @override
  bool operator ==(dynamic other) {
    if (!(other is Todo)) return false;

    return id == other.id &&
        title == other.title &&
        desc == other.desc &&
        isDone == other.isDone;
  }

  @override
  String toString() {
    return 'Todo{id: $id, title: $title, desc: $desc, isDone: $isDone}';
  }
}

class ToDoList extends MutableSource implements Cloneable<ToDoList> {
  List<Todo> list = <Todo>[];

  ToDoList();

  @override
  ToDoList clone() => ToDoList()..list.addAll(this.list);

  factory ToDoList.fromMap(Map map) {
    return ToDoList()
      ..list.addAll(
          map['list']?.map<Todo>((Map map) => Todo.fromMap(map))?.toList());
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

  @override
  Object getItemData(int index) => list[index];

  @override
  String getItemType(int index) => 'item';

  @override
  int get itemCount => list?.length ?? 0;

  @override
  void setItemData(int index, Object data) {
    list[index] = data;
  }
}

// connector: ConnOp<ToDoList, List<ItemBean>>(
//     get: (ToDoList toDoList) => toDoList.list
//         .map<ItemBean>((Todo toDo) => noReducer
//             ? ItemBean('toDoNoReducer', toDo)
//             : ItemBean('toDo', toDo))
//         .toList(),
//     set: (ToDoList toDoList, List<ItemBean> beans) {
//       toDoList.list.clear();
//       toDoList.list.addAll(beans
//           .map<Todo>((ItemBean bean) => bean.data)
//           .toList());
//     }),
