import 'basic.dart';

/// Accumulate a list of Middleware that enhances Disptach to the Store.
/// The wrapped direction of the Store.dispatch is from inside to outside.
StoreEnhancer<T> applyMiddleware<T>(List<Middleware<T>> middlewares) {
  if (middlewares == null || middlewares.isEmpty) {
    return null;
  } else {
    return (StoreCreator<T> creator) => (T initState, Reducer<T> reducer) {
          assert(middlewares != null && middlewares.isNotEmpty);

          final Store<T> store = creator(initState, reducer);
          final Dispatch initialValue = store.dispatch;
          store.dispatch = (Action action) {
            throw Exception(
                'Dispatching while constructing your middleware is not allowed. '
                'Other middleware would not be applied to this dispatch.');
          };
          store.dispatch = middlewares
              .map((Middleware<T> middleware) => middleware(
                    dispatch: (Action action) => store.dispatch(action),
                    getState: store.getState,
                  ))
              .fold(
                initialValue,
                (Dispatch previousValue, Dispatch Function(Dispatch) element) =>
                    element(previousValue),
              );

          return store;
        };
  }
}
