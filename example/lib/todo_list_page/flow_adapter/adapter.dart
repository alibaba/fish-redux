import 'package:fish_redux/fish_redux.dart';

import '../state.dart';
import '../todo_component/component.dart';
import 'reducer.dart';
import 'connector.dart';

FlowAdapter<PageState> get adapter =>
    FlowAdapter<PageState>(
      reducer: buildReducer(),
        view: (PageState state) =>
            DependentArray<PageState>(
              length: state.itemCount,
              builder: (int index) {
                return ToDoConnector(index: index) + ToDoComponent();
              },
            ));
