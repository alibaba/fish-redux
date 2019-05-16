import 'package:test/test.dart';
import 'package:fish_redux/fish_redux.dart';
import 'package:mockito/mockito.dart';

import 'redux/redux_test.dart' as redux;
import 'redux_adapter/redux_adapter_test.dart' as redux_adapter;
import 'redux_aop/redux_aop_test.dart' as redux_aop;
import 'redux_component/redux_component_test.dart' as redux_component;
import 'redux_connector/redux_connector_test.dart' as redux_connector;
import 'redux_middleware/redux_middleware_test.dart' as redux_middleware;
import 'redux_routes/redux_routes_test.dart' as redux_routes;
import 'utils/utils_test.dart' as utils;

class MockContext extends Mock implements Context<Object> {}

void onLogin(Action action, Context<Object> ctx) {
  ctx.dispatch(null);
}

// Real class
abstract class Cat {
  String sound();
  bool eatFood(String food, {bool hungry}) => true;
  int walk(List<String> places) => 0;
  void sleep() {}
  void hunt(String place, String prey) {}
  int lives = 9;
  Function() get a;
}

// Mock class
class MockCat extends Mock implements Cat {}

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
