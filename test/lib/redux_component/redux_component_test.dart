import 'package:test/test.dart';

import 'auto_dispose_test.dart' as auto_dispose;
import 'component_test.dart' as component;
import 'lifecycle_test.dart' as lifecycle;
import 'page_test.dart' as page;

void main() {
  group('redux_component_test', () {
    auto_dispose.main();
    component.main();
    lifecycle.main();
    page.main();
  });
}
