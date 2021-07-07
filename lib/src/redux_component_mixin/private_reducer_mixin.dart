import '../redux/redux.dart';
import '../redux_component/redux_component.dart';

/// usage
/// class MyComponent extends Component<T> with PrivateReducerMixin<T> {
///   MyComponent():super(
///     ///
///   );
/// }
mixin PrivateReducerMixin<T> on Logic<T> {
  /// 可空
  @override
  Reducer<T>? get protectedReducer {
    final Reducer<T>? superReducer = super.protectedReducer;
    return superReducer != null
        ? (T state, Action action) {
            if (action is PrivateAction && action.target == state) {
              return superReducer(state, action.asAction());
            }
            return state;
          }
        : null;
  }

  @override
  Dispatch createDispatch(Dispatch? effect, Dispatch next, Context<T> ctx) {
    final Dispatch superDispatch = super.createDispatch(effect, next, ctx);
    return (Action action) {
      if (action.type is! Lifecycle && action is! PrivateAction) {
        action = PrivateAction(
          action.type,
          payload: action.payload,
          ///todo（不确定）
          target: ctx.state as Object,
        );
      }
      return superDispatch(action);
    };
  }
}

class PrivateAction extends Action {
  final Object target;
  PrivateAction(Object type, {dynamic payload, required this.target})
      : super(type, payload: payload);

  Action asAction() => Action(type, payload: payload);
}
