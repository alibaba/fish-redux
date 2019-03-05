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

class AppProvider extends InheritedWidget {
  final Set<Dispatch> _onActionContainer = Set<Dispatch>();

  AppProvider({
    Key key,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static void Function() register(BuildContext context, Dispatch dispatch) {
    final AppProvider provider =
        context.inheritFromWidgetOfExactType(AppProvider);

    if (provider != null) {
      assert(!provider._onActionContainer.contains(dispatch),
          'Do not register a dispatch which is already existed');

      if (!provider._onActionContainer.contains(dispatch) && dispatch != null) {
        provider._onActionContainer.add(dispatch);
      }

      return () {
        provider._onActionContainer.remove(dispatch);
      };
    } else {
      return null;
    }
  }

  static void appBroadcast(BuildContext context, Action action) {
    final AppProvider provider = context.inheritFromWidgetOfExactType(
      AppProvider,
    );
    assert(provider != null, 'Please check if the AppProvider is mounted.');
    if (provider != null) {
      final List<OnAction> copy = provider._onActionContainer.toList(
        growable: false,
      );

      for (OnAction onAction in copy) {
        onAction(action);
      }
    }
  }

  @override
  bool updateShouldNotify(AppProvider oldWidget) => true;
}
