import 'package:test/test.dart';

import 'adapter_test.dart' as adapter;
import 'dynamic_adapter_test.dart' as dynamic_flow_dapter;
import 'source_adapter_test.dart' as source_flow_dapter;
import 'static_flow_adapter_test.dart' as static_flow_adapter;

void main() {
  group('redux_adapter_test', () {
    adapter.main();
    dynamic_flow_dapter.main();
    source_flow_dapter.main();
    static_flow_adapter.main();
  });
}
