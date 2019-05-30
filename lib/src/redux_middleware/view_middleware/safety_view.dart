import 'package:flutter/widgets.dart';

import '../../../fish_redux.dart';
import '../../redux/redux.dart';
import '../../redux_component/redux_component.dart';

ViewMiddleware<T> safetyView<T>(
    {Widget Function(dynamic, StackTrace,
            {AbstractComponent<dynamic> component, MixedStore<T> store})
        onError}) {
  return (AbstractComponent<dynamic> component, MixedStore<T> store) {
    return (ViewBuilder<dynamic> viewBuilder) {
      return isDebug()
          ? viewBuilder
          : (dynamic state, Dispatch dispatch, ViewService viewService) {
              try {
                return viewBuilder(state, dispatch, viewService);
              } catch (e, stackTrace) {
                return onError?.call(
                      e,
                      stackTrace,
                      component: component,
                      store: store,
                    ) ??
                    Container(width: 0, height: 0);
              }
            };
    };
  };
}
