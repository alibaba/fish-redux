import 'package:test/test.dart';

import 'redux/redux_test.dart' as redux;
import 'redux_adapter/redux_adapter_test.dart' as redux_adapter;
import 'redux_aop/redux_aop_test.dart' as redux_aop;
import 'redux_component/redux_component_test.dart' as redux_component;
import 'redux_connector/redux_connector_test.dart' as redux_connector;
import 'redux_middleware/redux_middleware_test.dart' as redux_middleware;
import 'redux_routes/redux_routes_test.dart' as redux_routes;
import 'utils/utils_test.dart' as utils;

void main() {
  group('all_test', () {
    redux.main();
    redux_adapter.main();
    redux_aop.main();
    redux_component.main();
    redux_connector.main();
    redux_middleware.main();
    redux_routes.main();
    utils.main();
  });
}
