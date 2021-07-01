import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import '../utils/utils.dart';
import 'basic.dart';
import 'dependencies.dart';
import 'helper.dart' as helper;

/// Four parts
/// 1. Reducer & ReducerFilter
/// 2. Effect
/// 3. Dependencies
/// 4. Key
abstract class Logic<T> implements AbstractLogic<T> {
  /// 可空 【logic.dart#82】
  final Reducer<T>? _reducer;
  /// 可空 【logic.dart#82】
  final ReducerFilter<T>? _filter;
  /// 可空
  final Effect<T>? _effect;
  /// 可空
  final Dependencies<T>? _dependencies;
  final Object Function(T state)? _key;

  /// for extends
  /// 可空 [private_reducer_mixin.dart#12]
  Reducer<T>? get protectedReducer => _reducer;
  /// 可空 【logic.dart#82】
  ReducerFilter<T>? get protectedFilter => _filter;
  /// 可空
  Effect<T>? get protectedEffect => _effect;
  /// 可空 【logic.dart#82】
  Dependencies<T>? get protectedDependencies => _dependencies;
  Reducer<T>? get protectedDependenciesReducer =>
      protectedDependencies?.createReducer();
  /// 可空
  Object Function(T state)? get protectedKey => _key;

  /// Used as function cache to improve operational efficiency
  final Map<String, Object> _resultCache = <String, Object>{};

  Logic({
    /// 可空
    Reducer<T>? reducer,
    Dependencies<T>? dependencies,
    ReducerFilter<T>? filter,
    /// 可空
    Effect<T>? effect,

    /// implement [StateKey] in T instead of using key in Logic.
    /// class T implements StateKey {
    ///   Object _key = UniqueKey();
    ///   Object key() => _key;
    /// }
    @deprecated Object Function(T state)? key,
  })  : _reducer = reducer,
        _filter = filter,
        _effect = effect,
        _dependencies = dependencies?.trim(),
        // ignore:deprecated_member_use_from_same_package
        assert(isAssignFrom<T, StateKey>() == false || key == null,
            'Implements [StateKey] in T instead of using key in Logic.'),
        _key = isAssignFrom<T, StateKey>()
            // ignore:avoid_as
            ? ((T state) => (state as StateKey).key())
            // ignore:deprecated_member_use_from_same_package
            : key;

  @override
  Type get propertyType => T;

  bool isSuperTypeof<K>() => Tuple0<K>() is Tuple0<T>;

  bool isTypeof<K>() => Tuple0<T>() is Tuple0<K>;

  static bool isAssignFrom<P, Q>() => Tuple0<P>() is Tuple0<Q>;

  /// if
  /// _resultCache['key'] = null;
  /// then
  /// _resultCache.containsKey('key') will be true;
  R cache<R>(String? key, Get<R> getter) => _resultCache.containsKey(key)
      ? _resultCache[key] as R
      : (_resultCache[key!] = getter() as dynamic) as R;

  /// 可空 【helper.dart#62】 protectedFilter?
  @override
  Reducer<T>? createReducer() => helper.filterReducer(
      combineReducers<T>(
          <Reducer<T>?>[protectedReducer, protectedDependenciesReducer]),
      protectedFilter);

  @override
  Object onReducer(Object state, Action action) =>
      cache<Reducer<T>?>('onReducer', createReducer)?.call(state as T, action) ??
      state;

  @override
  Dispatch createEffectDispatch(ContextSys<T> ctx, Enhancer<Object> enhancer) {
    return helper.createEffectDispatch<T>(

        /// enhance userEffect
        enhancer.effectEnhance(
          protectedEffect,
          this,
          ctx.store as Store<Object>,
        ),
        ctx);
  }

  @override
  Dispatch createNextDispatch(ContextSys<T> ctx, Enhancer<Object> enhancer) =>
      helper.createNextDispatch<T>(ctx);

  /// 可空 effectDispatch？
  @override
  Dispatch createDispatch(
    Dispatch? effectDispatch,
    Dispatch nextDispatch,
    Context<T> ctx,
  ) =>
      helper.createDispatch<T>(effectDispatch, nextDispatch, ctx);

  @override
  Object key(T state) => _key?.call(state) ?? ValueKey<Type>(runtimeType);

  @override
  Dependent<T>? slot(String type) => protectedDependencies?.slot(type);

  ///可空
  @override
  Dependent<T>? adapterDep() => protectedDependencies?.adapter;
}
