import 'package:flutter/widgets.dart';

import '../redux_component/redux_component.dart';

/// Define a basic behavior of routes.
abstract class AbstractRoutes {
  Widget buildPage(String path, dynamic arguments);
}

/// Each page has a unique store.
@immutable
class PageRoutes implements AbstractRoutes {
  final Map<String, Page<Object, dynamic>> pages;

  /// AppBus is a event-bus used to communicate between pages.
  final DispatchBus appBus;

  PageRoutes({
    @required this.pages,
    DispatchBus appBus,

    /// For common enhance
    void Function(String, Page<Object, dynamic>) visitor,
  })  : assert(pages != null, 'Expected the pages to be non-null value.'),
        appBus = appBus ?? DispatchBusDefault.shared {
    if (visitor != null) {
      pages.forEach(visitor);
    }
  }

  @override
  Widget buildPage(String path, dynamic arguments) =>
      pages[path]?.buildPage(arguments);
}
