import 'package:flutter/widgets.dart';

import '../redux/redux.dart';
import 'basic.dart';

class PageProvider extends InheritedWidget {
  final PageStore<Object> store;

  /// Used to store page data if needed
  final Map<String, Object> extra;

  const PageProvider({
    @required this.store,
    @required this.extra,
    @required Widget child,
    Key key,
  })  : assert(store != null),
        assert(child != null),
        super(key: key, child: child);

  static PageProvider tryOf(BuildContext context) {
    final PageProvider provider =
        context.inheritFromWidgetOfExactType(PageProvider);
    return provider;
  }

  @override
  bool updateShouldNotify(PageProvider oldWidget) =>
      store != oldWidget.store && extra != oldWidget.extra;
}

@deprecated
class AppProvider extends InheritedWidget {
  static final Set<Dispatch> _onActionContainer = Set<Dispatch>();
  final Map<String, dynamic> extra = <String, dynamic>{};

  AppProvider({
    Key key,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static void Function() register(BuildContext context, Dispatch dispatch) {
    assert(!_onActionContainer.contains(dispatch),
        'Do not register a dispatch which is already existed');

    if (!_onActionContainer.contains(dispatch) && dispatch != null) {
      _onActionContainer.add(dispatch);
    }

    return () {
      _onActionContainer.remove(dispatch);
    };
  }

  static void appBroadcast(BuildContext context, Action action) {
    final List<OnAction> copy = _onActionContainer.toList(
      growable: false,
    );

    for (OnAction onAction in copy) {
      onAction(action);
    }
  }

  @override
  bool updateShouldNotify(AppProvider oldWidget) => true;
}
