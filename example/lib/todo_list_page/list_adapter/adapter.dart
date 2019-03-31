import 'package:fish_redux/fish_redux.dart';

import '../state.dart';
import '../todo_component/component.dart';
import 'reducer.dart';

class ToDoListAdapter extends DynamicFlowAdapter<PageState> {
  ToDoListAdapter()
      : super(
          pool: <String, Component<Object>>{
            'toDo': ToDoComponent(),
          },
          connector: _ToDoListConnector(),
          reducer: buildReducer(),
        );
}

class _ToDoListConnector extends ConnOp<PageState, List<ItemBean>> {
  @override
  List<ItemBean> get(PageState state) {
    if (state.toDos?.isNotEmpty == true) {
      return state.toDos
          .map<ItemBean>((ToDoState data) => ItemBean('toDo', data))
          .toList(growable: true);
    } else {
      return <ItemBean>[];
    }
  }

  @override
  void set(PageState state, List<ItemBean> toDos) {
    if (toDos?.isNotEmpty == true) {
      state.toDos = List<ToDoState>.from(
          toDos.map<ToDoState>((ItemBean bean) => bean.data).toList());
    } else {
      state.toDos = <ToDoState>[];
    }
  }
}
