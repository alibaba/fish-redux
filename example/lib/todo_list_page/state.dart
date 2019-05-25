import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';
import 'package:sample/global_store/global_base_state.dart';
import 'package:sample/global_store/state.dart';
import 'report_component/component.dart';
import 'todo_component/component.dart';

class PageState with GlobalBaseState<PageState>{
  List<ToDoState> toDos;
  Color themeColor;

  @override
  PageState clone() {
    return PageState()..toDos = toDos;
  }

  @override
  PageState lessClone(GlobalState state)
  {
    return (state.themeColor == themeColor) ? this : clone()..themeColor = state.themeColor;
  }
}

PageState initState(Map<String, dynamic> args) {
  //just demo, do nothing here...
  return PageState();
}

class ReportConnector extends Reselect2<PageState, ReportState, int, int> {
  @override
  ReportState computed(int sub0, int sub1) {
    return ReportState()
      ..done = sub0
      ..total = sub1;
  }

  @override
  int getSub0(PageState state) {
    return state.toDos.where((ToDoState tds) => tds.isDone).toList().length;
  }

  @override
  int getSub1(PageState state) {
    return state.toDos.length;
  }

  @override
  void set(PageState state, ReportState subState) {
    throw Exception('Unexcepted to set PageState from ReportState');
  }
}
