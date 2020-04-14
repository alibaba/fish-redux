import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

@immutable
class TestStub extends StatefulWidget {
  final Widget testWidget;
  final String title;

  const TestStub(this.testWidget, {this.title = 'FlutterTest'});

  @override
  _StubState createState() => _StubState();
}

class _StubState extends State<TestStub> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: widget.title,
        home: Scaffold(
            appBar: AppBar(title: Text(widget.title)),
            body: widget.testWidget));
  }
}

class TestPage<T extends Cloneable<T>, P> extends Page<T, P> {
  TestPage({
    @required InitState<T, P> initState,
    List<Middleware<T>> middleware,
    @required ViewBuilder<T> view,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    Key Function(T) key,
  }) : super(
          initState: initState,
          middleware: middleware,
          view: view,
          reducer: reducer,
          filter: filter,
          effect: effect,
          dependencies: dependencies,
          shouldUpdate: shouldUpdate,
          wrapper: wrapper,
          key: key,
        );
}

class TestComponent<T extends Cloneable<T>> extends Component<T> {
  TestComponent({
    @required ViewBuilder<T> view,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    Key Function(T) key,
  }) : super(
            view: view,
            reducer: reducer,
            filter: filter,
            effect: effect,
            dependencies: dependencies,
            shouldUpdate: shouldUpdate,
            wrapper: wrapper,
            key: key);
}

class TestAdapter<T extends Cloneable<T>> extends Adapter<T> {
  TestAdapter({
    AdapterBuilder<T> adapter,
    Reducer<T> reducer,
    Effect<T> effect,
    ReducerFilter<T> filter,
    Dependencies<T> dependencies,
  }) : super(
            adapter: adapter,
            reducer: reducer,
            effect: effect,
            filter: filter,
            dependencies: dependencies);
}

class TestStaticFlowAdapter<T extends Cloneable<T>>
    extends StaticFlowAdapter<T> {
  TestStaticFlowAdapter({
    @required List<Dependent<T>> slots,
    Reducer<T> reducer,
    Effect<T> effect,
    ReducerFilter<T> filter,
  }) : super(slots: slots, reducer: reducer, effect: effect, filter: filter);
}

class TestDynamicFlowAdapter<T extends Cloneable<T>>
    extends DynamicFlowAdapter<T> {
  TestDynamicFlowAdapter({
    @required Map<String, AbstractLogic<Object>> pool,
    @required ConnOp<T, List<ItemBean>> connector,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
  }) : super(
            pool: pool,
            connector: connector,
            reducer: reducer,
            effect: effect,
            filter: filter);
}

class TestSourceFlowAdapter<T extends AdapterSource>
    extends SourceFlowAdapter<T> {
  TestSourceFlowAdapter({
    @required Map<String, AbstractLogic<Object>> pool,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
  }) : super(
          pool: pool,
          reducer: reducer,
          effect: effect,
          filter: filter,
        );
}
