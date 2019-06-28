import '../../redux/redux.dart';
import '../../utils/utils.dart';

/// Middleware for print action dispatch.
/// It works on debug mode.
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

              // if (prevState == nextState) {
              //   print('[$tag] warning: ${action.type} has not been used.');
              // }

              print('========== [$tag] ================');
            }
          : next;
    };
  };
}
