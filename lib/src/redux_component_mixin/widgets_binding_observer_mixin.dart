import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux_component/redux_component.dart';

/// usage
/// class MyComponent extends Component<T> with WidgetsBindingObserverMixin<T> {
///   MyComponent():super(
///     ///
///   );
/// }
/// For Both [Component] & [Page]
mixin WidgetsBindingObserverMixin<T> on Component<T> {
  @override
  _WidgetsBindingObserverStfState<T> createState() =>
      _WidgetsBindingObserverStfState<T>();
}

class _WidgetsBindingObserverStfState<T> extends ComponentState<T>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    ctx.onLifecycle(LifecycleCreator.didChangeAppLifecycleState(state));
  }
}
