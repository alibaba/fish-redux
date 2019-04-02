import 'package:flutter/widgets.dart';

import '../redux/redux.dart';
import '../redux_component/redux_component.dart';
import '../utils/utils.dart';

/// Define a basic behavior of routes.
abstract class AbstractRoutes {
  Widget buildPage(String path, Map<String, dynamic> map);
}

/// Use RouteAction.route in reducer.
///     asReducer<T>({
///       RouteAction.route: _route,
///     });
///     T _route(T state, Action action) {}
///
/// Never use RouteAction._route. It is hidden.
enum RouteAction {
  route,
  _route,
}

class _RouteActionCreator {
  static Action _route(String path, Map<String, dynamic> map) => Action(
        RouteAction._route,
        payload: Tuple2<String, Map<String, dynamic>>(path, map),
      );
}

/// Multi-page(a route component is a page) sharing a store.
class AppRoutes<T> implements AbstractRoutes {
  final Map<String, Dependent<T>> pages;
  final PageStore<T> _store;

  AppRoutes({
    @required T preloadedState,
    @required this.pages,
    Reducer<T> reducer,
    List<Middleware<T>> middleware,
  })  : assert(preloadedState != null,
            'Expected the preloadedState to be non-null value.'),
        assert(pages != null, 'Expected the slots to be non-null value.'),
        _store = createPageStore<T>(
          preloadedState,
          _createReducer<T>(pages, reducer),
          applyMiddleware<T>(middleware),
        );

  @override
  Widget buildPage(String path, Map<String, dynamic> map) {
    final Dependent<T> dependent = pages[path];
    if (dependent != null) {
      _store.dispatch(_RouteActionCreator._route(path, map));
    }
    return dependent?.buildComponent(_store, _store.getState);
  }

  static Reducer<T> _createReducer<T>(
      Map<String, Dependent<T>> slots, Reducer<T> reducer) {
    final Map<String, SubReducer<T>> subReducerMap = slots.map((String path,
            Dependent<T> dependent) =>
        MapEntry<String, SubReducer<T>>(path, dependent.createSubReducer()));

    final Reducer<T> mainReducer = combineReducers(<Reducer<T>>[
      reducer,
      combineSubReducers(subReducerMap.entries
          .map((MapEntry<String, SubReducer<T>> entry) => entry.value))
    ]);

    return (T state, Action action) {
      /// Forward RouteAction._route action to the matching subReducer with same payload.
      if (action.type == RouteAction._route) {
        final Tuple2<String, Map<String, dynamic>> payload = action.payload;
        final String path = payload.i0;
        final SubReducer<T> subReducer = subReducerMap[path];
        assert(subReducer != null);
        return subReducer(
          state,
          Action(RouteAction.route, payload: payload.i1),
          false,
        );
      }
      return mainReducer(state, action);
    };
  }
}

/// Each page has a unique store.
class PageRoutes implements AbstractRoutes {
  final Map<String, Page<Object, Map<String, dynamic>>> pages;

  PageRoutes({
    @required this.pages,
  }) : assert(pages != null, 'Expected the pages to be non-null value.');

  @override
  Widget buildPage(String path, Map<String, dynamic> map) =>
      pages[path]?.buildPage(map);
}

/// How to define ?
///     MainRoutes extends HybridRoutes {
///       MainRoutes():super(
///           routes: [
///             PageRoutes(
///               pages: <String, Page<Object, Map<String, dynamic>>>{
///                 'home': HomePage(),
///                 'detail': DetailPage(),
///               },
///             ),
///             AppRoutes<T>(
///               preloadedState: T(),
///               middleware:[],
///               slots: {
///                 'message': MsgConn() + MessageComponent(),
///                 'personal': PersonalConn() + PersonalComponent(),
///               },
///             ),
///           ]
///         );
///     }
///
/// How to use ?
///     const Routes mainRoutes = MainRoutes();
///     mainRoutes.buildPage('home', {});
abstract class HybridRoutes implements AbstractRoutes {
  final List<AbstractRoutes> routes;

  const HybridRoutes({
    @required this.routes,
  }) : assert(routes != null);

  @override
  Widget buildPage(String path, Map<String, dynamic> map) {
    for (AbstractRoutes aRoutes in routes) {
      final Widget result = aRoutes.buildPage(path, map);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

/// How to define ?
///     MainRoutes extends HybridRoutes with OnRouteNotFoundMixin {
///       MainRoutes():super(
///           routes: [
///             PageRoutes(
///               pages: <String, Page<Object, Map<String, dynamic>>>{
///                 'home': HomePage(),
///                 'detail': DetailPage(),
///               },
///             ),
///             AppRoutes<T>(
///               preloadedState: T(),
///               middleware:[],
///               pages: {
///                 'message': MsgConn() + MessageComponent(),
///                 'personal': PersonalConn() + PersonalComponent(),
///               },
///             ),
///           ]
///         );
///
///       Widget onRouteNotFound(String path, Map<String, dynamic> map) {
///         return Text('route of $path not found.');
///       }
///     }
///
/// How to use ?
///     const Routes mainRoutes = MainRoutes();
///     mainRoutes.buildPage('test', {});
mixin OnRouteNotFoundMixin on AbstractRoutes {
  @override
  Widget buildPage(String path, Map<String, dynamic> map) =>
      super.buildPage(path, map) ?? onRouteNotFound(path, map);

  Widget onRouteNotFound(String path, Map<String, dynamic> map);
}
