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

class _ToDoListConnector extends ConnOp<PageState, List<ItemBean>>

    /// [https://github.com/alibaba/fish-redux/issues/482] #482
    with
        ReselectMixin<PageState, List<ItemBean>> {
  @override
  void set(PageState state, List<ItemBean> toDos) {
    if (toDos?.isNotEmpty == true) {
      state.toDos = List<ToDoState>.from(
          toDos.map<ToDoState>((ItemBean bean) => bean.data).toList());
    } else {
      state.toDos = <ToDoState>[];
    }
  }

  @override
  List<ItemBean> computed(PageState state) {
    if (state.toDos?.isNotEmpty == true) {
      return state.toDos
          .map<ItemBean>((ToDoState data) => ItemBean('toDo', data))
          .toList(growable: true);
    } else {
      return <ItemBean>[];
    }
  }

  /// watched factors
  @override
  List<dynamic> factors(PageState state) {
    return <dynamic>[state.toDos];
  }
}
