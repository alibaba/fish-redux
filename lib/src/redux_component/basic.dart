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
typedef OnAction = dynamic Function(Action action);

/// Predicate if a component should be updated when the store is changed.
typedef ShouldUpdate<T> = bool Function(T old, T now);

/// Interrupt if not null not false
/// bool for sync-functions, interrupted if true
/// Futur<void> for async-functions, should always be interrupted.
typedef Effect<T> = dynamic Function(Action action, Context<T> ctx);

/// Because Effect<T> is an aysnc-function, if it has some self-state, we should use HigherEffect<T>
typedef HigherEffect<T> = OnAction Function(Context<T> ctx);

/// If an exception is thrown out, we may have some need to handle it.
typedef OnError<T> = bool Function(Exception exception, Context<T> ctx);

/// todo
abstract class EffectBroadcast {
  /// Broadcast in all component receivers;
  void broadcastEffect(Action action, {Dispatch excluded});

  /// Register a receiver and return the unregister function
  void Function() registerComponentReceiver(Dispatch dispatch);
}

/// todo
abstract class InterStoreBroadcast {
  /// Broadcast in all store receivers;
  void broadcast(Action action, {Dispatch excluded});

  /// Register a receiver and return the unregister function
  void Function() registerStoreReceiver(Dispatch dispatch);
}

/// todo
abstract class SlotBuilder {
  /// <String, Dependent<T>> slots
  Widget buildComponent(String name);
}

/// todo
typedef EffectMiddleware<T> = Composable<HigherEffect<dynamic>> Function(
    AbstractLogic<dynamic>, MixedStore<T>);

// todo
typedef ViewMiddleware<T> = Composable<ViewBuilder<dynamic>> Function(
    AbstractComponent<dynamic>, MixedStore<T>);

typedef AdapterMiddleware<T> = Composable<AdapterBuilder<dynamic>> Function(
    AbstractAdapter<dynamic>, MixedStore<T>);

/// todo
abstract class ViewEnhancer<T> {
  ViewBuilder<K> viewEnhance<K>(
    ViewBuilder<K> view,
    AbstractComponent<K> component,
  );
}

/// todo
abstract class AdapterEnhancer<T> {
  AdapterBuilder<K> adapterEnhance<K>(
    AdapterBuilder<K> adapterBuilder,
    AbstractAdapter<K> logic,
  );
}

/// todo
abstract class EffectEnhancer<T> {
  HigherEffect<K> effectEnhance<K>(
    HigherEffect<K> higherEffect,
    AbstractLogic<K> logic,
  );
}

/// A mixed store with inter-component, inter-store communication & slot-build
abstract class MixedStore<T> extends Store<T>
    implements
        EffectBroadcast,
        InterStoreBroadcast,
        SlotBuilder,
        ViewEnhancer<T>,
        AdapterEnhancer<T>,
        EffectEnhancer<T> {}

/// Seen in view-part or adapter-part
abstract class ViewService {
  /// The way to build adapter which is configured in Dependencies.adapter
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
abstract class Context<T> extends AutoDispose {
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

  /// Get|Set extra data in context if needed.
  Map<String, Object> get extra;

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

  MixedStore<dynamic> get store;
}

/// Representation of each dependency
abstract class Dependent<T> {
  Get<Object> subGetter(Get<T> getter);

  SubReducer<T> createSubReducer();

  Widget buildComponent(MixedStore<Object> store, Get<T> getter);

  /// P state
  ListAdapter buildAdapter(
    Object state,
    Dispatch dispatch,
    ViewService viewService,
  );

  ContextSys<Object> createContext({
    MixedStore<Object> store,
    BuildContext buildContext,
    Get<T> getState,
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
  OnAction createHandlerOnAction(ContextSys<T> ctx);

  /// To create each instance's broadcast-handler
  /// It is same as side-effect-action-handler by defalut.
  OnAction createHandlerOnBroadcast(
      OnAction onAction, ContextSys<T> ctx, Dispatch parentDispatch);

  /// To create each instance's dispatch
  /// Dispatch is the most important api for users which is provided by framework
  Dispatch createDispatch(
      OnAction onAction, ContextSys<T> ctx, Dispatch parentDispatch);

  /// To create each instance's context
  ContextSys<T> createContext({
    MixedStore<Object> store,
    BuildContext buildContext,
    Get<T> getState,
  });

  /// To create each instance's key (for recycle) if needed
  Object key(T state);

  /// It's a convenient way to create a dependency
  @deprecated
  Dependent<K> asDependent<K>(AbstractConnector<K, T> connector);

  /// Find a dependent by name
  Dependent<T> slot(String name);
}

abstract class AbstractComponent<T> implements AbstractLogic<T> {
  /// How to render & How to update
  ViewUpdater<T> createViewUpdater(
    ContextSys<T> ctx,
    void Function() markNeedsBuild,
  );

  /// How to build component instance
  Widget buildComponent(MixedStore<Object> store, Get<T> getter);
}

abstract class AbstractAdapter<T> implements AbstractLogic<T> {
  ListAdapter buildAdapter(T state, Dispatch dispatch, ViewService viewService);
}

/// Because a main reducer will be very complicated with multiple level's state.
/// When a reducer is slow to handle an action, maybe we should use ReducerFilter to improve the performance.
typedef ReducerFilter<T> = bool Function(T state, Action action);
