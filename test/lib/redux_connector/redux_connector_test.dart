import 'package:test/test.dart';

import 'map_like_test.dart' as mapLike;
import 'reselect_test.dart' as reselect;

void main() {
  group('redux_connector_test', () {
    reselect.main();
    mapLike.main();
  });
}
