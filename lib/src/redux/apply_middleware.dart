import 'basic.dart';

/// Accumulate a list of Middleware that enhances Dispatch to the Store.
/// The wrapped direction of the Store.dispatch is from inside to outside.
StoreEnhancer<T> applyMiddleware<T>(List<Middleware<T>> middleware) {
  return middleware == null || middleware.isEmpty
      ? null
      : (StoreCreator<T> creator) => (T initState, Reducer<T> reducer) {
            assert(middleware != null && middleware.isNotEmpty);

            final Store<T> store = creator(initState, reducer);
            final Dispatch initialValue = store.dispatch;
            store.dispatch = (Action action) {
              throw Exception(
                  'Dispatching while constructing your middleware is not allowed. '
                  'Other middleware would not be applied to this dispatch.');
            };
            store.dispatch = middleware
                .map((Middleware<T> middleware) => middleware(
                      dispatch: (Action action) => store.dispatch(action),
                      getState: store.getState,
                    ))
                .fold(
                  initialValue,
                  (Dispatch previousValue,
                          Dispatch Function(Dispatch) element) =>
                      element(previousValue),
                );

            return store;
          };
}
