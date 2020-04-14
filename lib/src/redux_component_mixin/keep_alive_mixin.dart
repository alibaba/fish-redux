import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux_component/redux_component.dart';

/// usage
/// class MyComponent extends Component<T> with KeepAliveMixin<T> {
///   MyComponent():super(
///     ///
///   );
/// }
/// Only For [Component]
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
    return ctx.buildWidget();
  }
}

/// usage
/// class MyComponent extends Component<T> {
///   MyComponent():super(
///     wrapper: keepAliveClientWrapper,
///   );
/// }
/// For Both [Component] & [Page]
Widget keepAliveClientWrapper(Widget child) => _KeepAliveWidget(child);

class _KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const _KeepAliveWidget(this.child);

  @override
  State<StatefulWidget> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
