import 'package:fish_redux/fish_redux.dart';
import '../page/state.dart';
import '../todo_component/component.dart';
import '../todo_component/state.dart';

class ListDemoComponent extends Adapter<PageState> {
  ListDemoComponent()
      : super(
          dependencies: FlowDependencies<PageState>(
              (PageState indexs) {
                final List<Dependent<PageState>> _dependents = <Dependent<PageState>>[];
                int index = 0;
                for (ToDoState item in indexs?.toDos ?? []) {
                  _dependents.add(DemoPageModelListStringConnector(toDoStates: indexs?.toDos, index: index) + TodoComponent());
                  index++;
                }
                 return DependentArray<PageState>.fromList(
                    _dependents
                  );
              }),
        );
}

class DemoPageModelListStringConnector extends ConnOp<PageState, ToDoState> {
  DemoPageModelListStringConnector({this.toDoStates, this.index}) : super();

  final List<ToDoState> toDoStates;
  final int index;

  @override
  ToDoState get(PageState state) {
    return toDoStates[index];
  }

  @override
  void set(PageState state, ToDoState subState) {
    state.toDos[index] = subState;
  }
}
