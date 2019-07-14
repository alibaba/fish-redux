import 'package:flutter/widgets.dart' hide Action;

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
  void reassemble();
}

/// A little different with Dispatch (with if it is interrupted).
/// bool for sync-functions, interrupted if true
/// Futur<void> for async-functions, should always be interrupted.
// typedef OnAction = Dispatch;

/// Predicate if a component should be updated when the store is changed.
typedef ShouldUpdate<T> = bool Function(T old, T now);

/// Interrupt if not null not false
/// bool for sync-functions, interrupted if true
/// Futur<void> for async-functions, should always be interrupted.
typedef Effect<T> = dynamic Function(Action action, Context<T> ctx);

/// AOP on view
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
  Widget buildComponent(String name);

  /// Get BuildContext from the host-widget
  BuildContext get context;

  /// Broadcast action(the intent) in app (inter-pages)
  void broadcast(Action action);

  /// Broadcast in all component receivers;
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
  /// 1. Define a new ComponentState
  ///    class CustomStfState<T> extends ComponentState<T> with SingleTickerProviderStateMixin {}
  /// 2. Override the createState method of the Component with the newly defined CustomStfState.
  ///    @override
  ///    CustomStfState createState() => CustomStfState();
  /// 3. Get the CustomStfState via context.stfState in Effect.
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

/// Representation of each dependency
abstract class Dependent<T> {
  Get<Object> subGetter(Get<T> getter);

  SubReducer<T> createSubReducer();

  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  });

  /// P state
  ListAdapter buildAdapter(ContextSys<Object> ctx);

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
  Dispatch createOnEffect(ContextSys<T> ctx, Enhancer<Object> enhancer);

  /// To create each instance's side-effect-action-handler
  Dispatch createAfterEffect(ContextSys<T> ctx, Enhancer<Object> enhancer);

  /// To create each instance's dispatch
  /// Dispatch is the most important api for users which is provided by framework
  Dispatch createDispatch(
    Dispatch onEffect,
    Dispatch next,
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

abstract class AbstractAdapter<T> implements AbstractLogic<T> {
  ListAdapter buildAdapter(ContextSys<T> ctx);
}

/// Because a main reducer will be very complicated with multiple level's state.
/// When a reducer is slow to handle an action, maybe we should use ReducerFilter to improve the performance.
typedef ReducerFilter<T> = bool Function(T state, Action action);

///
abstract class DispatchBus {
  void attach(DispatchBus parent);

  void detach();

  void dispatch(Action action, {Dispatch excluded});

  void broadcast(Action action, {DispatchBus excluded});

  void Function() registerReceiver(Dispatch dispatch);
}
