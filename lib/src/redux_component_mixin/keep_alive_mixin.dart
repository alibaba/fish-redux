import 'package:flutter/widgets.dart';

import '../redux_component/redux_component.dart';

/// usage
/// class MyComponent extends Component<T> with KeepAliveMixin<T> {
///   MyComponent():super(
///     ///
///   );
/// }
mixin KeepAliveMixin<T> on Component<T> {
  @override
  ComponentState<T> createState() => _KeepAliveStfState<T>();
}

class _KeepAliveStfState<T> extends ComponentState<T>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return mainCtx.buildWidget();
  }
}
