import 'package:test/test.dart';

import 'adapter_test.dart' as adapter;
import 'auto_dispose_test.dart' as auto_dispose;
import 'component_test.dart' as component;
import 'dynamic_adapter_test.dart' as dynamic_flow_dapter;
import 'lifecycle_test.dart' as lifecycle;
import 'page_test.dart' as page;
import 'static_flow_adapter_test.dart' as static_flow_adapter;
import 'store_test.dart' as store;

void main() {
  group('all_test', () {
    store.main();
    page.main();
    component.main();
    lifecycle.main();
    auto_dispose.main();
    adapter.main();
    static_flow_adapter.main();
    dynamic_flow_dapter.main();
  });
}
