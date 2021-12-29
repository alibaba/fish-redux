import 'package:test/test.dart';

import 'redux/redux_test.dart' as redux;
import 'redux_component/redux_component_test.dart' as redux_component;

void main() {
  group('all_test', () {
    redux.main();
    redux_component.main();
  });
}
