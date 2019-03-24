import 'package:flutter/foundation.dart';

import '../redux/redux.dart';

/// for debug or report
enum $DebugOrReport {
  debugUpdate,
  reportBuildError,
  reportSetStateError,
  reportOtherError,
}

class $DebugOrReportCreator {
  static Action debugUpdate(String name) =>
      Action($DebugOrReport.debugUpdate, payload: name);

  static Action reportBuildError(Object exception, StackTrace stackTrace) =>
      Action($DebugOrReport.reportBuildError,
          payload: flutterErrorDetails(exception, stackTrace));

  static Action reportSetStateError(
          FlutterError exception, StackTrace stackTrace) =>
      Action($DebugOrReport.reportSetStateError,
          payload: flutterErrorDetails(exception, stackTrace));

  static Action reportOtherError(
          FlutterError exception, StackTrace stackTrace) =>
      Action($DebugOrReport.reportOtherError,
          payload: flutterErrorDetails(exception, stackTrace));

  static FlutterErrorDetails flutterErrorDetails(
      Object exception, StackTrace stackTrace) {
    return FlutterErrorDetails(
      exception: exception,
      stack: stackTrace,
      library: 'fish-redux',
    );
  }
}

/// action-type which starts with '$' should be interrupted,
/// like $DebugOrReport
bool shouldBeInterruptedBeforeReducer(Action action) {
  final Object actionType = action.type;
  return actionType != null && actionType.toString().startsWith('\$');
}
