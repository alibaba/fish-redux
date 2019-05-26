import 'package:flutter/material.dart';
import '../global_store/state.dart';
import '../todo_list_page/todo_component/component.dart';

class TodoEditState implements GlobalBaseState<TodoEditState> {
  ToDoState toDo;

  TextEditingController nameEditController;
  TextEditingController descEditController;

  FocusNode focusNodeName;
  FocusNode focusNodeDesc;

  @override
  Color themeColor;

  int themeIdx;
  List<Color> themeColorSlots;

  @override
  TodoEditState clone() {
    return TodoEditState()
      ..nameEditController = nameEditController
      ..descEditController = descEditController
      ..focusNodeName = focusNodeName
      ..focusNodeDesc = focusNodeDesc
      ..toDo = toDo
      ..themeIdx = themeIdx
      ..themeColorSlots = themeColorSlots;
  }
}

TodoEditState initState(ToDoState arg) {
  final TodoEditState state = TodoEditState();
  state.toDo = arg?.clone() ?? ToDoState();
  state.nameEditController = TextEditingController(text: arg?.title);
  state.descEditController = TextEditingController(text: arg?.desc);
  state.focusNodeName = FocusNode();
  state.focusNodeDesc = FocusNode();
  state.themeIdx = 0;
  state.themeColorSlots = [Colors.green, Colors.red, Colors.black, Colors.blue];
  return state;
}
