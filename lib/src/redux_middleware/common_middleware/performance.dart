import '../../redux/redux.dart';
import '../../utils/utils.dart';

/// Middleware for print action dispatch performance by time consuming.
/// It works on debug mode.
Middleware<T> performanceMiddleware<T>({String tag = 'redux'}) {
  return ({Dispatch dispatch, Get<T> getState}) {
    return (Dispatch next) {
      return isDebug()
          ? (Action action) {
              final int markPrev = DateTime.now().microsecondsSinceEpoch;
              next(action);
              final int markNext = DateTime.now().microsecondsSinceEpoch;
              print('$tag performance: ${action.type} ${markNext - markPrev}');
            }
          : next;
    };
  };
}
