import 'package:flutter/widgets.dart' hide Action;

import 'basic.dart';

class PageProvider extends InheritedWidget {
  final MixedStore<Object> store;

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
