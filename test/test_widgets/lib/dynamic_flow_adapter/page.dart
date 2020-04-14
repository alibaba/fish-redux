import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import '../test_base.dart';
import 'action.dart';
import 'dynamic_flow_adapter.dart';
import 'state.dart';

Widget pageView(
  ToDoList state,
  Dispatch dispatch,
  ViewService viewService,
) {
  print('build pageView');
  final ListAdapter listAdapter = viewService.buildAdapter();
  return Column(
    children: <Widget>[
      Expanded(
          child: ListView.builder(
              itemBuilder: listAdapter.itemBuilder,
              itemCount: listAdapter.itemCount)),
      Row(
        children: <Widget>[
          Expanded(
              child: GestureDetector(
            child: Container(
              key: ValueKey('Add'),
              height: 68.0,
              color: Colors.green,
              alignment: AlignmentDirectional.center,
              child: Text('Add'),
            ),
            onTap: () {
              print('dispatch Add');
              dispatch(Action(PageAction.onAdd));
            },
            onLongPress: () {
              print('dispatch broadcast');
              viewService.broadcastEffect(const Action(ToDoAction.broadcast));
            },
          )),
        ],
      )
    ],
  );
}

const Map<String, dynamic> pageInitParams = <String, dynamic>{
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

bool pageEffect(Action action, Context<ToDoList> ctx) {
  if (action.type == PageAction.onAdd) {
    print('page onAdd');
    ctx.broadcastEffect(Action(ToDoListAction.onAdd, payload: Todo.mock()));
    return true;
  }

  return false;
}

ToDoList initState(Map map) => ToDoList.fromMap(map);

Widget createDynamicAdapterWidget(BuildContext context) {
  return TestPage<ToDoList, Map>(
          view: pageView,
          initState: initState,
          effect: pageEffect,
          dependencies: Dependencies<ToDoList>(
              adapter: NoneConn<ToDoList>() + testAdapter))
      .buildPage(pageInitParams);
}
