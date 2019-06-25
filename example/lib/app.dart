import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import 'global_store/state.dart';
import 'global_store/store.dart';
import 'todo_edit_page/page.dart';
import 'todo_list_page/page.dart';

//create global page helper
// Page<T, dynamic> pageConfiguration<T extends GlobalBaseState>(
//     Page<T, dynamic> page) {
//   return page

//         ///connect with app-store
//         ..connectExtraStore(GlobalStore.store,
//             (T pagestate, GlobalState appState) {
//           return pagestate.themeColor == appState.themeColor
//               ? pagestate
//               : ((pagestate.clone())..themeColor = appState.themeColor);
//         })

//       ///updateMiddleware
//       /// TODO
//       // ..updateMiddleware(
//       //   view: (List<ViewMiddleware<T>> viewMiddleware) {
//       //     viewMiddleware.add(safetyView<T>());
//       //   },
//       //   adapter: (List<AdapterMiddleware<T>> adapterMiddleware) {
//       //     adapterMiddleware.add(safetyAdapter<T>());
//       //   },
//       // )
//       ;
// }

Widget createApp() {
  final AbstractRoutes routes = PageRoutes(
    pages: <String, Page<Object, dynamic>>{
      'todo_list': ToDoListPage(),
      'todo_edit': TodoEditPage(),
    },
    visitor: (String path, Page<Object, dynamic> page) {
      /// XXX
      if (page.isTypeof<GlobalBaseState>()) {
        page.connectExtraStore<GlobalState>(GlobalStore.store,
            (Object pagestate, GlobalState appState) {
          final GlobalBaseState p = pagestate;
          if (p.themeColor == appState.themeColor) {
            return pagestate;
          } else {
            if (pagestate is Cloneable) {
              final Object copy = pagestate.clone();
              final GlobalBaseState newState = copy;
              newState.themeColor = appState.themeColor;
              return newState;
            }
          }
        });
      }

      // }
      ///updateMiddleware
      /// TODO
      // ..updateMiddleware(
      //   view: (List<ViewMiddleware<T>> viewMiddleware) {
      //     viewMiddleware.add(safetyView<T>());
      //   },
      //   adapter: (List<AdapterMiddleware<T>> adapterMiddleware) {
      //     adapterMiddleware.add(safetyAdapter<T>());
      //   },
      // )
    },
  );

  return MaterialApp(
    title: 'Fluro',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: routes.buildPage('todo_list', null),
    onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute<Object>(builder: (BuildContext context) {
        return routes.buildPage(settings.name, settings.arguments);
      });
    },
  );
}
