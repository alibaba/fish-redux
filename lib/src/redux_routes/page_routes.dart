import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux_component/redux_component.dart';

/// Define a basic behavior of routes.
abstract class AbstractRoutes {
  Widget buildPage(String path, dynamic arguments);
}

/// Each page has a unique store.
@immutable
class PageRoutes implements AbstractRoutes {
  final Map<String, Page<Object, dynamic>> pages;

  PageRoutes({
    @required this.pages,

    /// For common enhance
    void Function(String, Page<Object, dynamic>) visitor,
  }) : assert(pages != null, 'Expected the pages to be non-null value.') {
    if (visitor != null) {
      pages.forEach(visitor);
    }
  }

  @override
  Widget buildPage(String path, dynamic arguments) =>
      pages[path]?.buildPage(arguments);
}
