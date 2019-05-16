import 'package:flutter/widgets.dart';

import '../../redux/redux.dart';
import '../../redux_component/redux_component.dart';

/// type = {0, 1}
AdapterMiddleware<T> safetyAdapter<T>({
  Widget Function(dynamic, StackTrace,
          {AbstractAdapter<dynamic> adapter, MixedStore<T> store, int type})
      onError,
}) {
  return (AbstractAdapter<dynamic> adapter, MixedStore<T> store) {
    return (AdapterBuilder<dynamic> viewBuilder) {
      return (dynamic state, Dispatch dispatch, ViewService viewService) {
        try {
          final ListAdapter result = viewBuilder(state, dispatch, viewService);
          return ListAdapter((BuildContext buildContext, int index) {
            try {
              return result.itemBuilder(buildContext, index);
            } catch (e, stackTrace) {
              return onError?.call(
                    e,
                    stackTrace,
                    adapter: adapter,
                    store: store,
                    type: 1,
                  ) ??
                  Container(width: 0, height: 0);
            }
          }, result.itemCount);
        } catch (e, stackTrace) {
          final Widget errorWidget = onError?.call(
            e,
            stackTrace,
            adapter: adapter,
            store: store,
            type: 0,
          );
          return errorWidget == null
              ? const ListAdapter(null, 0)
              : ListAdapter(
                  (BuildContext buildContext, int index) => errorWidget, 1);
        }
      };
    };
  };
}
