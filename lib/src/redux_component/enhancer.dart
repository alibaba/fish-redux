import 'package:fish_redux/src/redux_component/helper.dart';
import 'package:flutter/cupertino.dart';

import '../redux/redux.dart';
import 'basic.dart';

@immutable
class EnhancerDefault<T> implements Enhancer<T> {
  final StoreEnhancer<T> _storeEnhancer;
  final ViewMiddleware<T> _viewEnhancer;
  final EffectMiddleware<T> _effectEnhancer;
  final AdapterMiddleware<T> _adapterEnhancer;

  EnhancerDefault({
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
    List<Middleware<T>> middleware,
  })  : _storeEnhancer = applyMiddleware<T>(middleware),
        _viewEnhancer = mergeViewMiddleware<T>(viewMiddleware),
        _effectEnhancer = mergeEffectMiddleware<T>(effectMiddleware),
        _adapterEnhancer = mergeAdapterMiddleware<T>(adapterMiddleware);

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
  HigherEffect<K> effectEnhance<K>(
    HigherEffect<K> higherEffect,
    AbstractLogic<K> logic,
    Store<T> store,
  ) =>
      _effectEnhancer
          ?.call(logic, store)
          ?.call(_inverterHigherEffect<K>(higherEffect)) ??
      higherEffect;

  @override
  StoreCreator<T> storeEnhance(StoreCreator<T> creator) =>
      _storeEnhancer?.call(creator) ?? creator;

  HigherEffect<dynamic> _inverterHigherEffect<K>(
          HigherEffect<K> higherEffect) =>
      higherEffect == null ? null : (Context<dynamic> ctx) => higherEffect(ctx);

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
