import 'package:fish_redux/fish_redux.dart';

import '../state.dart';
import '../todo_component/component.dart';
import 'reducer.dart';

class ToDoListAdapter extends SourceFlowAdapter<PageState> {
  ToDoListAdapter()
      : super(
          pool: <String, Component<Object>>{
            'toDo': ToDoComponent(),
          },
          reducer: buildReducer(),
        );
}
