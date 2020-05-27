import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import 'auto_dispose.dart';

/// Component's view part
/// 1.State is used to decide how to render
/// 2.Dispatch is used to send actions
/// 3.ViewService is used to build sub-components or adapter.
typedef ViewBuilder<T> = Widget Function(
  T state,
  Dispatch dispatch,
  ViewService viewService,
);

/// Define a base ListAdapter which is used for ListView.builder.
/// Many small listAdapters could be merged to a bigger one.
class ListAdapter {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  const ListAdapter(this.itemBuilder, this.itemCount);
}

/// Adapter's view part
/// 1.State is used to decide how to render
/// 2.Dispatch is used to send actions
/// 3.ViewService is used to build sub-components or adapter.
typedef AdapterBuilder<T> = ListAdapter Function(
  T state,
  Dispatch dispatch,
  ViewService viewService,
);

/// Data driven ui
/// 1. How to render
/// 2. When to update
abstract class ViewUpdater<T> {
  Widget buildWidget();
  void didUpdateWidget();
  void onNotify();
  void forceUpdate();
  void clearCache();
}

/// A little different with Dispatch (with if it is interrupted).
/// bool for sync-functions, interrupted if true
/// Future<void> for async-functions, should always be interrupted.
// typedef OnAction = Dispatch;

/// Predicate if a component should be updated when the store is changed.
typedef ShouldUpdate<T> = bool Function(T old, T now);

/// Interrupt if not null not false
/// bool for sync-functions, interrupted if true
/// Future<void> for async-functions, should always be interrupted.
typedef Effect<T> = dynamic Function(Action action, Context<T> ctx);

/// AOP on view
/// usage
/// ViewMiddleware<T> safetyView<T>(
///     {Widget Function(dynamic, StackTrace,
///             {AbstractComponent<dynamic> component, Store<T> store})
///         onError}) {
///   return (AbstractComponent<dynamic> component, Store<T> store) {
///     return (ViewBuilder<dynamic> next) {
///       return isDebug()
///           ? next
///           : (dynamic state, Dispatch dispatch, ViewService viewService) {
///               try {
///                 return next(state, dispatch, viewService);
///               } catch (e, stackTrace) {
///                 return onError?.call(
///                       e,
///                       stackTrace,
///                       component: component,
///                       store: store,
///                     ) ??
///                     Container(width: 0, height: 0);
///               }
///             };
///     };
///   };
/// }
typedef ViewMiddleware<T> = Composable<ViewBuilder<dynamic>> Function(
  AbstractComponent<dynamic>,
  Store<T>,
);

/// AOP on adapter
typedef AdapterMiddleware<T> = Composable<AdapterBuilder<dynamic>> Function(
  AbstractAdapter<dynamic>,
  Store<T>,
);

/// AOP on effect
/// usage
/// EffectMiddleware<T> pageAnalyticsMiddleware<T>() {
///   return (AbstractLogic<dynamic> logic, Store<T> store) {
///     return (Effect<dynamic> effect) {
///       return effect == null ? null : (Action action, Context<dynamic> ctx) {
///         if (logic is Page<dynamic, dynamic>) {
///           print('${logic.runtimeType} ${action.type.toString()} ${ctx.hashCode}');
///         }
///         return effect(action, ctx);
///       };
///     };
///   };
/// }
typedef EffectMiddleware<T> = Composable<Effect<dynamic>> Function(
  AbstractLogic<dynamic>,
  Store<T>,
);

/// AOP in page on store, view, adapter, effect...
abstract class Enhancer<T> {
  ViewBuilder<K> viewEnhance<K>(
    ViewBuilder<K> view,
    AbstractComponent<K> component,
    Store<T> store,
  );

  AdapterBuilder<K> adapterEnhance<K>(
    AdapterBuilder<K> adapterBuilder,
    AbstractAdapter<K> logic,
    Store<T> store,
  );

  Effect<K> effectEnhance<K>(
    Effect<K> effect,
    AbstractLogic<K> logic,
    Store<T> store,
  );

  StoreCreator<T> storeEnhance(StoreCreator<T> creator);

  void unshift({
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
  });

  void append({
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
  });
}

/// AOP End

abstract class ExtraData {
  /// Get|Set extra data in context if needed.
  Map<String, Object> get extra;
}

/// Seen in view-part or adapter-part
abstract class ViewService implements ExtraData {
  /// The way to build adapter which is configured in Dependencies.list
  ListAdapter buildAdapter();

  /// The way to build slot component which is configured in Dependencies.slots
  Widget buildComponent(String name, {Widget defaultWidget});

  /// Get BuildContext from the host-widget
  BuildContext get context;

  /// Broadcast action(the intent) in app (inter-pages)
  void broadcast(Action action);

  /// Broadcast in all component receivers;
  /// Dispatch is enough. Use [Dispatch] instead of [broadcastEffect]
  /// [Dispatch] = [SelfEffect] | ([broadcastEffect] & [store.dispatch])
  @deprecated
  void broadcastEffect(Action action, {bool excluded});
}

///  Seen in effect-part
abstract class Context<T> extends AutoDispose implements ExtraData {
  /// Get the latest state
  T get state;

  /// The way to send action, which will be consumed by self, or by broadcast-module and store.
  dynamic dispatch(Action action);

  /// Get BuildContext from the host-widget
  BuildContext get context;

  /// In general, we should not need this field.
  /// When we have to use this field, it means that we have encountered difficulties.
  /// This is a contradiction between presentation & logical separation, and Flutter's Widgets system.
  ///
  /// How to use ?
  /// For example, we want to use SingleTickerProviderStateMixin
  /// We should
  /// 1. Define a new Component mixin SingleTickerProviderMixin
  ///    class MyComponent<T> extends Component<T> with SingleTickerProviderMixin<T> {}
  /// 2. Get the CustomStfState via context.stfState in Effect.
  ///    /// Through BuildContext -> StatefulElement -> State
  ///    final TickerProvider tickerProvider = context.stfState;
  ///    AnimationController controller = AnimationController(vsync: tickerProvider);
  ///    context.dispatch(ActionCreator.createController(controller));
  State get stfState;

  /// The way to build slot component which is configured in Dependencies.slots
  /// such as custom mask or dialog
  Widget buildComponent(String name);

  /// Broadcast action in app (inter-stores)
  void broadcast(Action action);

  /// Broadcast in all component receivers;
  void broadcastEffect(Action action, {bool excluded});

  /// add observable
  void Function() addObservable(Subscribe observable);

  void forceUpdate();

  /// listen on the changes of some parts of <T>.
  void Function() listen({
    bool Function(T, T) isChanged,
    void Function() onChange,
  });
}

/// Seen in framework-component
abstract class ContextSys<T> extends Context<T> implements ViewService {
  /// Response to lifecycle calls
  void onLifecycle(Action action);

  void bindForceUpdate(void Function() forceUpdate);

  Store<dynamic> get store;

  Enhancer<dynamic> get enhancer;

  DispatchBus get bus;
}

abstract class AbstractAdapterBuilder<T> {
  ListAdapter buildAdapter(ContextSys<T> ctx);
}

/// Representation of each dependency
abstract class Dependent<T> implements AbstractAdapterBuilder<Object> {
  Get<Object> subGetter(Get<T> getter);

  SubReducer<T> createSubReducer();

  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  });

  ContextSys<Object> createContext(
    Store<Object> store,
    BuildContext buildContext,
    Get<T> getState, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  });

  bool isComponent();

  bool isAdapter();
}

/// Encapsulation of the logic part of the component
/// The logic is divided into two parts, Reducer & SideEffect.
abstract class AbstractLogic<T> {
  /// To create a reducer<T>
  Reducer<T> get reducer;

  /// To solve Reducer<Object> is neither a subtype nor a supertype of Reducer<T> issue.
  Object onReducer(Object state, Action action);

  /// To create each instance's side-effect-action-handler
  Dispatch createEffectDispatch(ContextSys<T> ctx, Enhancer<Object> enhancer);

  /// To create each instance's side-effect-action-handler
  Dispatch createNextDispatch(ContextSys<T> ctx, Enhancer<Object> enhancer);

  /// To create each instance's dispatch
  /// Dispatch is the most important api for users which is provided by framework
  Dispatch createDispatch(
    Dispatch effectDispatch,
    Dispatch nextDispatch,
    ContextSys<T> ctx,
  );

  /// To create each instance's context
  ContextSys<T> createContext(
    Store<Object> store,
    BuildContext buildContext,
    Get<T> getState, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  });

  /// To create each instance's key (for recycle) if needed
  Object key(T state);

  /// Find a dependent by name
  Dependent<T> slot(String name);

  /// Get a adapter-dependent
  Dependent<T> adapterDep();

  Type get propertyType;
}

abstract class AbstractComponent<T> implements AbstractLogic<T> {
  /// How to build component instance
  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  });
}

abstract class AbstractAdapter<T>
    implements AbstractLogic<T>, AbstractAdapterBuilder<T> {}

/// Because a main reducer will be very complicated with multiple level's state.
/// When a reducer is slow to handle an action, maybe we should use ReducerFilter to improve the performance.
typedef ReducerFilter<T> = bool Function(T state, Action action);

/// implement [StateKey] in T .
/// class T implements StateKey {
///   Object _key = UniqueKey();
///   Object key() => _key;
/// }
/// see [https://github.com/alibaba/fish-redux/issues/461]
abstract class StateKey {
  Object key();
}

/// Define a DispatchBus
abstract class DispatchBus {
  void attach(DispatchBus parent);

  void detach();

  void dispatch(Action action, {Dispatch excluded});

  void broadcast(Action action, {DispatchBus excluded});

  void Function() registerReceiver(Dispatch dispatch);
}
