import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import 'component.dart';
import 'dependencies.dart';

typedef InitState<T, P> = T Function(P params);

abstract class Page<T, P> extends Component<T> {
  Page({
    @required this.initState,
    this.middleware,
    Effect<T> effect,
    Reducer<T> reducer,
    Dependencies<T> dependencies,
    ViewBuilder<T> view,
    ShouldUpdate<T> shouldUpdate,
  })  : assert(initState != null),
        super(
          effect: effect,
          dependencies: dependencies,
          reducer: reducer,
          view: view,
          shouldUpdate: shouldUpdate,
        );

  final InitState<T, P> initState;
  final List<Middleware<T>> middleware;

  ///  build about
  Widget buildPage(P param) => _PageWidget<T, P>(
        param: param,
        page: this,
      );
}

class _PageWidget<T, P> extends StatefulWidget {
  final P param;
  final Page<T, P> page;

  const _PageWidget({
    Key key,
    @required this.param,
    @required this.page,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageState<T, P>();
}

class _PageState<T, P> extends State<_PageWidget<T, P>> {
  Store<T> _store;
  DispatchBus _pageBus;
  T state;

  final Map<String, Object> extra = <String, Object>{};

  @override
  void initState() {
    super.initState();
    state = widget.page.initState(widget.param);
    _pageBus = DispatchBusDefault();
    _store = createStore(state, widget.page.createReducer(), middleware: widget.page.middleware);
    _pageBus.registerReceiver(_store.dispatch);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widget.page.buildComponent(_store, _store.getState, dispatchBus: _pageBus);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
