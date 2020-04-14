import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux_component/redux_component.dart';

/// usage
/// class MyComponent extends Component<T> with SingleTickerProviderMixin<T> {
///   MyComponent():super(
///     ///
///   );
/// }
/// For Both [Component] & [Page]
mixin SingleTickerProviderMixin<T> on Component<T> {
  @override
  _SingleTickerProviderStfState<T> createState() =>
      _SingleTickerProviderStfState<T>();
}

class _SingleTickerProviderStfState<T> extends ComponentState<T>
    with SingleTickerProviderStateMixin {
  /// fix SingleTickerProviderStateMixin dispose bug
  @override
  void dispose() {
    disposeCtx();
    super.dispose();
  }
}
