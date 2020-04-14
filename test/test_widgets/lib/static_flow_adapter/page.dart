import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import '../test_base.dart';
import 'state.dart';
import 'static_flow_adapter.dart';

Widget pageView(
  ToDoList state,
  Dispatch dispatch,
  ViewService viewService,
) {
  print('build pageView');
  ListAdapter listAdapter = viewService.buildAdapter();
  return ListView.builder(
      itemBuilder: listAdapter.itemBuilder, itemCount: listAdapter.itemCount);
}

const Map pageInitParams = <String, dynamic>{
  'list': [
    <String, dynamic>{
      'id': '0',
      'title': 'title-0',
      'desc': 'desc-0',
      'isDone': false
    },
    <String, dynamic>{
      'id': '1',
      'title': 'title-1',
      'desc': 'desc-1',
      'isDone': false
    },
    <String, dynamic>{
      'id': '2',
      'title': 'title-2',
      'desc': 'desc-2',
      'isDone': false
    },
    <String, dynamic>{
      'id': '3',
      'title': 'title-3',
      'desc': 'desc-3',
      'isDone': true
    }
  ]
};

ToDoList initState(Map map) => ToDoList.fromMap(map);

Widget createStaticAdapterWidget(BuildContext context) {
  return TestPage<ToDoList, Map>(
          initState: initState,
          view: pageView,
          dependencies: Dependencies<ToDoList>(
              adapter: NoneConn<ToDoList>() + testAdapter))
      .buildPage(pageInitParams);
}
