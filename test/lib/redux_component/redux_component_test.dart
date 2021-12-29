import 'package:test/test.dart';

import 'component_test.dart' as component;
import 'lifecycle_test.dart' as lifecycle;
import 'page_test.dart' as page;

void main() {
  group('redux_component_test', () {
    component.main();
    lifecycle.main();
    page.main();
  });
}
