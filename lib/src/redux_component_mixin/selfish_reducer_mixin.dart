import 'package:fish_redux/fish_redux.dart';

/// usage
/// 1. State implements Compare interface
/// class MyState implements Cloneable<MyState>,Comparison<MyState>{
///   ...
///   int businessId;
///
///   @override
///   bool compare(MyState other) {
///     return businessId==other.businessId;
///   }
///   ...
/// }
///
/// 2. Component add SelfishReducerMixin
/// class MyComponent extends Component<T> with SelfishReducerMixin<T> {
///   MyComponent():super(
///     ///
///   );
/// }
///
/// 3. Use SelfishAction instead of Action
/// enum MyAction { edit, done,}
/// class MyActionCreator {
///   static Action editAction(MyState myState) {
///     return SelfishAction(MyAction.edit, payload: myState);
///   }
///
///   static Action doneAction() {
///     return SelfishAction(MyAction.done);
///   }
/// }
mixin SelfishReducerMixin<T extends Comparison<T>> on Logic<T> {
  @override
  Reducer<T> get protectedReducer {
    final Reducer<T> superReducer = super.protectedReducer;
    return superReducer != null
        ? (T state, Action action) {
      if (action is SelfishAction ) {
        if(action.target is T &&state.compare(action.target)){
          return superReducer(state, action.asAction());
        }else{
          return state;
        }
      }else{
        return superReducer(state, action);
      }
    }
        : null;
  }

  @override
  Dispatch createDispatch(Dispatch effect, Dispatch next, Context<T> ctx) {
    final Dispatch superDispatch = super.createDispatch(effect, next, ctx);
    return (Action action) {
      if (action is SelfishAction) {
        action.attachTarget(ctx.state);
      }
      superDispatch(action);
    };
  }
}

class SelfishAction extends Action{
  Object target;
  SelfishAction(Object type, {dynamic payload})
      : super(type, payload: payload);

  void attachTarget(Object target)=>this.target=target;

  Action asAction() => Action(type, payload: payload);
}

abstract class Comparison<T extends Comparison<T>> {
  bool compare(T other);
}