import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'logic.dart';

class PrivateAction extends Action {
  final Object current;
  PrivateAction(Object type, {dynamic payload, this.current})
      : super(type, payload: payload);

  Action asAction() => Action(type, payload: payload);
}

mixin PrivateReducerMixin<T> on Logic<T> {
  @override
  Reducer<T> get privateReducer {
    final Reducer<T> superReducer = super.privateReducer;
    return superReducer != null
        ? (T state, Action action) {
            if (action is PrivateAction && action.current == state) {
              return superReducer(state, action.asAction());
            }
            return state;
          }
        : null;
  }

  @override
  Dispatch createDispatch(
      OnAction onAction, Context<T> ctx, Dispatch parentDispatch) {
    final Dispatch superDispatch = super.createDispatch(
      onAction,
      ctx,
      parentDispatch,
    );
    return (Action action) {
      if (action is! PrivateAction) {
        action = PrivateAction(
          action.type,
          payload: action.payload,
          current: ctx.state,
        );
      }
      superDispatch(action);
    };
  }
}
