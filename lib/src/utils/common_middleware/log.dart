import 'package:fish_redux/fish_redux.dart';

import '../../redux/redux.dart';
import '../../utils/debug.dart';

Middleware<T> logMiddleware<T>({
  String tag = 'redux',
  String Function(T) monitor,
}) {
  return ({Dispatch dispatch, Get<T> getState}) {
    return (Dispatch next) {
      return isDebug()
          ? (Action action) {
              print('---------- [$tag] ----------');
              print('[$tag] ${action.type} ${action.payload}');

              final T prevState = getState();
              if (monitor != null) {
                print('[$tag] prev-state: ${monitor(prevState)}');
              }

              next(action);

              final T nextState = getState();
              if (monitor != null) {
                print('[$tag] next-state: ${monitor(nextState)}');
              }

              if (prevState == nextState) {
                print('[$tag] warning: ${action.type} has not been used.');
              }

              print('========== [$tag] ================');
            }
          : next;
    };
  };
}
