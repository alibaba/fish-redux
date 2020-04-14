import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux_component/redux_component.dart';

/// usage
/// class MyComponent extends Component<T> with TickerProviderMixin<T> {
///   MyComponent():super(
///     ///
///   );
/// }
/// For Both [Component] & [Page]
mixin TickerProviderMixin<T> on Component<T> {
  @override
  _TickerProviderStfState<T> createState() => _TickerProviderStfState<T>();
}

class _TickerProviderStfState<T> extends ComponentState<T>
    with TickerProviderStateMixin {
  /// fix TickerProviderStateMixin dispose bug
  @override
  void dispose() {
    disposeCtx();
    super.dispose();
  }
}
