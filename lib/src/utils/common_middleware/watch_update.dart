import 'package:fish_redux/fish_redux.dart';

import '../../redux/redux.dart';
import '../../utils/debug.dart';

/// Middleware for print action detail when middleware update,
/// It works on debug mode.
Middleware<T> watchUpdateMiddleware<T>({String tag = 'redux'}) {
  return ({Dispatch dispatch, Get<T> getState}) {
    return (Dispatch next) {
      return isDebug()
          ? (Action action) {
              next(action);
              if (action.type == $DebugOrReport.debugUpdate) {
                print('$tag update: ${action.payload}');
              }
            }
          : next;
    };
  };
}
