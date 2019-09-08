import 'package:meta/meta.dart';

import '../redux/redux.dart';
import '../redux_component/redux_component.dart';

/// usage
/// class MyComponent extends Component<T> with PrivateReducerMixin<T> {
///   MyComponent():super(
///     ///
///   );
/// }
///
/// custom usage
/// class MyComponent extends Component<T> with PrivateReducerMixin<T> {
///   MyComponent():super(
///     ///
///   );
///
///   //-->if true: Automatically convert Action to PrivateAction
///   //-->if false: You must manually create a PrivateAction
///   //default value -->  true
///   //see [PrivateReducerMixin.wantAutoConvert]
///   @override
///   bool get wantAutoConvert => true;
///
///
///   //default value --> state==other
///   //see [PrivateReducerMixin.compare]
///   @override
///   bool compare(PrivateTestState state, dynamic other) {
///     if (other is PrivateTestState) {
///       return state.XxxBusinessId == other.XxxBusinessId;
///     } else {
///       return super.compare(state, other);
///     }
///   }
///
/// }
mixin PrivateReducerMixin<T> on Logic<T> {
  @protected
  bool get wantAutoConvert => true;

  @protected
  bool compare(T state, dynamic other) => state == other;

  @override
  Reducer<T> get protectedReducer {
    final Reducer<T> superReducer = super.protectedReducer;
    return superReducer != null
        ? (T state, Action action) {
            if (action is PrivateAction) {
              return compare(state, action.target)
                  ? superReducer(state, action.asAction())
                  : state;
            } else {
              return superReducer(state, action);
            }
          }
        : null;
  }

  @override
  Dispatch createDispatch(Dispatch effect, Dispatch next, Context<T> ctx) {
    final Dispatch superDispatch = super.createDispatch(effect, next, ctx);
    return (Action action) {
      if (action is PrivateAction) {
        action.target ??= ctx.state;
      } else if (wantAutoConvert && action.type is! Lifecycle) {
        action = PrivateAction(action.type,
            payload: action.payload, target: ctx.state);
      }
      superDispatch(action);
    };
  }
}

class PrivateAction extends Action {
  Object target;

  PrivateAction(Object type, {dynamic payload, this.target})
      : super(type, payload: payload);

  Action asAction() => Action(type, payload: payload);
}
