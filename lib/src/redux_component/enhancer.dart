import 'package:fish_redux/src/redux_component/helper.dart';

import '../redux/redux.dart';
import 'basic.dart';

class EnhancerDefault<T> implements Enhancer<T> {
  StoreEnhancer<T> _storeEnhancer;
  ViewMiddleware<T> _viewEnhancer;
  EffectMiddleware<T> _effectEnhancer;
  AdapterMiddleware<T> _adapterEnhancer;

  final List<Middleware<T>> _middleware = <Middleware<T>>[];
  final List<ViewMiddleware<T>> _viewMiddleware = <ViewMiddleware<T>>[];
  final List<EffectMiddleware<T>> _effectMiddleware = <EffectMiddleware<T>>[];
  final List<AdapterMiddleware<T>> _adapterMiddleware =
      <AdapterMiddleware<T>>[];

  EnhancerDefault({
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
  }) {
    append(
      middleware: middleware,
      viewMiddleware: viewMiddleware,
      effectMiddleware: effectMiddleware,
      adapterMiddleware: adapterMiddleware,
    );
  }

  @override
  void unshift({
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
  }) {
    if (middleware != null) {
      _middleware.insertAll(0, middleware);
      _storeEnhancer = applyMiddleware<T>(_middleware);
    }
    if (viewMiddleware != null) {
      _viewMiddleware.insertAll(0, viewMiddleware);
      _viewEnhancer = mergeViewMiddleware<T>(_viewMiddleware);
    }
    if (effectMiddleware != null) {
      _effectMiddleware.insertAll(0, effectMiddleware);
      _effectEnhancer = mergeEffectMiddleware<T>(_effectMiddleware);
    }
    if (adapterMiddleware != null) {
      _adapterMiddleware.insertAll(0, adapterMiddleware);
      _adapterEnhancer = mergeAdapterMiddleware<T>(_adapterMiddleware);
    }
  }

  @override
  void append({
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
  }) {
    if (middleware != null) {
      _middleware.addAll(middleware);
      _storeEnhancer = applyMiddleware<T>(_middleware);
    }
    if (viewMiddleware != null) {
      _viewMiddleware.addAll(viewMiddleware);
      _viewEnhancer = mergeViewMiddleware<T>(_viewMiddleware);
    }
    if (effectMiddleware != null) {
      _effectMiddleware.addAll(effectMiddleware);
      _effectEnhancer = mergeEffectMiddleware<T>(_effectMiddleware);
    }
    if (adapterMiddleware != null) {
      _adapterMiddleware.addAll(adapterMiddleware);
      _adapterEnhancer = mergeAdapterMiddleware<T>(_adapterMiddleware);
    }
  }

  @override
  ViewBuilder<K> viewEnhance<K>(
    ViewBuilder<K> view,
    AbstractComponent<K> component,
    Store<T> store,
  ) =>
      _viewEnhancer?.call(component, store)?.call(_inverterView<K>(view)) ??
      view;

  @override
  AdapterBuilder<K> adapterEnhance<K>(
    AdapterBuilder<K> adapterBuilder,
    AbstractAdapter<K> logic,
    Store<T> store,
  ) =>
      _adapterEnhancer
          ?.call(logic, store)
          ?.call(_inverterAdapter<K>(adapterBuilder)) ??
      adapterBuilder;

  @override
  Effect<K> effectEnhance<K>(
    Effect<K> effect,
    AbstractLogic<K> logic,
    Store<T> store,
  ) =>
      _effectEnhancer?.call(logic, store)?.call(_inverterEffect<K>(effect)) ??
      effect;

  @override
  StoreCreator<T> storeEnhance(StoreCreator<T> creator) =>
      _storeEnhancer?.call(creator) ?? creator;

  Effect<dynamic> _inverterEffect<K>(Effect<K> effect) => effect == null
      ? null
      : (Action action, Context<dynamic> ctx) => effect(action, ctx);

  ViewBuilder<dynamic> _inverterView<K>(ViewBuilder<K> view) => view == null
      ? null
      : (dynamic state, Dispatch dispatch, ViewService viewService) =>
          view(state, dispatch, viewService);

  AdapterBuilder<dynamic> _inverterAdapter<K>(AdapterBuilder<K> adapter) =>
      adapter == null
          ? null
          : (dynamic state, Dispatch dispatch, ViewService viewService) =>
              adapter(state, dispatch, viewService);
}
