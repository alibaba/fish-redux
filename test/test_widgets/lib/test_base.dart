import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

class TestStub extends StatefulWidget {
  final Widget testWidget;
  final String title;

  TestStub(this.testWidget, {this.title = 'FlutterTest'});

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
    List<Middleware<T>> middlewares,
    @required ViewBuilder<T> view,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    OnError<T> onError,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    Key Function(T) key,
  }) : super(
          initState: initState,
          middlewares: middlewares,
          view: view,
          reducer: reducer,
          filter: filter,
          effect: effect,
          higherEffect: higherEffect,
          onError: onError,
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
    HigherEffect<T> higherEffect,
    OnError<T> onError,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    Key Function(T) key,
  }) : super(
            view: view,
            reducer: reducer,
            filter: filter,
            effect: effect,
            higherEffect: higherEffect,
            onError: onError,
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
    HigherEffect<T> higherEffect,
    OnError<T> onError,
    ReducerFilter<T> filter,
    Dependencies<T> dependencies,
  }) : super(
            adapter: adapter,
            reducer: reducer,
            effect: effect,
            higherEffect: higherEffect,
            onError: onError,
            filter: filter,
            dependencies: dependencies);
}

class TestStaticFlowAdapter<T extends Cloneable<T>>
    extends StaticFlowAdapter<T> {
  TestStaticFlowAdapter({
    @required List<Dependent<T>> slots,
    Reducer<T> reducer,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    OnError<T> onError,
    ReducerFilter<T> filter,
  }) : super(
            slots: slots,
            reducer: reducer,
            effect: effect,
            higherEffect: higherEffect,
            onError: onError,
            filter: filter);
}

class TestDynamicFlowAdapter<T extends Cloneable<T>>
    extends DynamicFlowAdapter<T> {
  TestDynamicFlowAdapter({
    @required Map<String, AbstractLogic<Object>> pool,
    @required Connector<T, List<ItemBean>> connector,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    OnError<T> onError,
  }) : super(
            pool: pool,
            connector: connector,
            reducer: reducer,
            effect: effect,
            higherEffect: higherEffect,
            onError: onError,
            filter: filter);
}
