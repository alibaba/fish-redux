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

class ReportConnector extends ConnOp<PageState, ReportState> {
  @override
  ReportState get(PageState state) {
    final ReportState reportState = ReportState();
    reportState.total = state.toDos.length;
    reportState.done =
        state.toDos.where((ToDoState tds) => tds.isDone).toList().length;
    return reportState;
  }

  @override
  void set(PageState state, ReportState subState) {}
}
