import 'package:fish_redux/fish_redux.dart';

import '../todo_list_page/todo_component/component.dart';
import 'effect.dart';
import 'state.dart';
import 'view.dart';

class TodoEditPage extends Page<TodoEditState, ToDoState> {
  TodoEditPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          view: buildView,

          /// 页面私有AOP，如果需要
          // middleware: <Middleware<TodoEditState>>[
          //   logMiddleware(tag: 'TodoEditPage'),
          // ],
        );
}
