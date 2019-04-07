import '../redux/redux.dart';

enum Lifecycle {
  initState,
  didChangeDependencies,
  build,

  reassemble,

  didUpdateWidget,
  deactivate,
  dispose,

  //adapter
  appear,
  disappear,
}

class LifecycleCreator {
  static Action initState() => const Action(Lifecycle.initState);

  static Action build() => const Action(Lifecycle.build);

  static Action reassemble() => const Action(Lifecycle.reassemble);

  static Action dispose() => const Action(Lifecycle.dispose);

  static Action didUpdateWidget() => const Action(Lifecycle.didUpdateWidget);

  static Action didChangeDependencies() =>
      const Action(Lifecycle.didChangeDependencies);

  static Action deactivate() => const Action(Lifecycle.deactivate);

  static Action appear(int index) => Action(Lifecycle.appear, payload: index);

  static Action disappear(int index) =>
      Action(Lifecycle.disappear, payload: index);
}
