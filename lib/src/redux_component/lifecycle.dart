import 'package:flutter/scheduler.dart';

import '../redux/redux.dart';

enum Lifecycle {
  initState,
  didChangeDependencies,
  build,

  reassemble,

  didUpdateWidget,
  deactivate,

  /// willDispose
  dispose,
  // didDisposed,

  // adapter
  appear,
  disappear,

  // app
  didChangeAppLifecycleState,
}

class LifecycleCreator {
  static Action initState() => const Action(Lifecycle.initState);

  static Action build(String name) => Action(Lifecycle.build, payload: name);

  static Action reassemble() => const Action(Lifecycle.reassemble);

  static Action dispose() => const Action(Lifecycle.dispose);

  // static Action didDisposed() => const Action(Lifecycle.didDisposed);

  static Action didUpdateWidget() => const Action(Lifecycle.didUpdateWidget);

  static Action didChangeDependencies() =>
      const Action(Lifecycle.didChangeDependencies);

  static Action deactivate() => const Action(Lifecycle.deactivate);

  static Action appear(int index) => Action(Lifecycle.appear, payload: index);

  static Action disappear(int index) =>
      Action(Lifecycle.disappear, payload: index);

  static Action didChangeAppLifecycleState(AppLifecycleState state) =>
      Action(Lifecycle.didChangeAppLifecycleState, payload: state);
}
