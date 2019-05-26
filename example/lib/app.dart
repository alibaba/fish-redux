import 'package:flutter/material.dart';

import 'package:fish_redux/fish_redux.dart';
import 'global_store/base_state.dart';
import 'global_store/state.dart';
import 'global_store/store.dart';
import 'todo_edit_page/page.dart';
import 'todo_list_page/page.dart';

//create global page helper
Page<T, dynamic> connectExtraStore<T extends GlobalBaseState<T>>(
    Page<T, dynamic> page) {
  return page
    ..connectExtraStore(GlobalStore.store, (T pagestate, GlobalState appState) {
      return pagestate.lessClone(appState);
    });
}

Widget createApp() {
  final AbstractRoutes routes = HybridRoutes(routes: <AbstractRoutes>[
    PageRoutes(
      pages: <String, Page<Object, dynamic>>{
        'todo_list': connectExtraStore(ToDoListPage()),
        'todo_edit': connectExtraStore(TodoEditPage())
      },
    ),
  ]);

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
