import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'logic.dart';

class PrivateAction extends Action {
  final Object ref;
  PrivateAction(Object type, {dynamic payload, this.ref})
      : super(type, payload: payload);

  Action asAction() => Action(type, payload: payload);
}

mixin PrivateReducerMixin<T> on Logic<T> {
  @override
  Reducer<T> get reducer {
    final Reducer<T> superReducer = super.reducer;
    return (T state, Action action) {
      if (action is PrivateAction && action.ref == state) {
        return superReducer(state, action.asAction());
      }
      return state;
    };
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
          ref: ctx.state,
        );
      }
      superDispatch(action);
    };
  }
}
