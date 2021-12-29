import 'package:fish_redux/fish_redux.dart';

import '../todo_component/state.dart';

class PageState 
    implements Cloneable<PageState> {
  List<ToDoState> toDos;

  @override
  PageState clone() {
    return PageState()
      ..toDos = toDos;
  }
}

PageState initState(Map<String, dynamic> args) {
  //just demo, do nothing here...
  return PageState();
}
