import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';
import '../global_store/state.dart';
import 'report_component/component.dart';
import 'todo_component/component.dart';

class PageState extends MutableSource
    implements GlobalBaseState, Cloneable<PageState> {
  List<ToDoState> toDos;

  @override
  Color themeColor;

  @override
  PageState clone() {
    return PageState()
      ..toDos = toDos
      ..themeColor = themeColor;
  }

  @override
  Object getItemData(int index) => toDos[index];

  @override
  String getItemType(int index) => 'toDo';

  @override
  int get itemCount => toDos?.length ?? 0;

  @override
  void setItemData(int index, Object data) => toDos[index] = data;
}

PageState initState(Map<String, dynamic> args) {
  //just demo, do nothing here...
  return PageState();
}

class ReportConnector extends ConnOp<PageState, ReportState>
    with ReselectMixin<PageState, ReportState> {
  @override
  ReportState computed(PageState state) {
    return ReportState()
      ..done = state.toDos.where((ToDoState tds) => tds.isDone).length
      ..total = state.toDos.length;
  }

  @override
  List<dynamic> factors(PageState state) {
    return <int>[
      state.toDos.where((ToDoState tds) => tds.isDone).length,
      state.toDos.length
    ];
  }

  @override
  void set(PageState state, ReportState subState) {
    throw Exception('Unexcepted to set PageState from ReportState');
  }
}
