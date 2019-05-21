import '../../redux/redux.dart';
import '../../redux_component/redux_component.dart';
import '../../utils/utils.dart';

/// Middleware for print action detail when middleware update,
/// It works on debug mode.
/// EffectMiddleware
Middleware<T> watchUpdateMiddleware<T>({String tag = 'redux'}) {
  return ({Dispatch dispatch, Get<T> getState}) {
    return (Dispatch next) {
      return isDebug()
          ? (Action action) {
              next(action);

              /// todo
              // if (action.type == $DebugOrReport.debugUpdate) {
              print('$tag update: ${action.payload}');
              // }
            }
          : next;
    };
  };
}
