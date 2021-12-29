import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Page, Action;
import 'state.dart';
import '../todo_component/state.dart';
import '../report_component/connector.dart';
import '../report_component/component.dart';
import '../todo_adapter/adapter.dart';

/// Middleware for print action dispatch.
/// It works on debug mode.
Middleware<T> logMiddleware<T>({
  String tag = 'redux',
  String Function(T) monitor,
}) {
  return ({Dispatch dispatch, Get<T> getState}) {
    return (Dispatch next) {
      return (Action action) {
        print('---------- [$tag] ----------');
        print('[$tag] ${action.type} ${action.payload}');

        final T prevState = getState();
        if (monitor != null) {
          print('[$tag] prev-state: ${monitor(prevState)}');
        }

        next(action);

        final T nextState = getState();
        if (monitor != null) {
          print('[$tag] next-state: ${monitor(nextState)}');
        }

        print('========== [$tag] ================');
      };
    };
  };
}

class ToDoListPage extends Page<PageState, Map<String, dynamic>> {
  ToDoListPage()
      : super(
            initState: initState,
            reducer: buildReducer(),
            dependencies: Dependencies<PageState>(
              adapter: NoneConn<PageState>() + ListDemoComponent(),
              slots: <String, Dependent<PageState>>{
                'report': ReportConnector() + ReportComponent()
              },
            ),
            middleware: <Middleware<PageState>>[
              logMiddleware<PageState>(
                  tag: 'ToDoListPage',
                  monitor: (PageState state) {
                    return '111';
                  })
            ],
            effect: combineEffects<PageState>(<Object, SubEffect<PageState>>{
              Lifecycle.initState: _init,
            }),
            view: (PageState state, Dispatch dispatch,
                ComponentContext<PageState> ctx) {
              final List<Widget> _ws = ctx.buildComponents();
              return Scaffold(
                  body: Stack(children: <Widget>[
                Container(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) =>
                        _ws[index],
                    itemCount: _ws?.length ?? 0,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ctx.buildComponent('report'),
                )
              ]));
            });
}

void _init(Action action, ComponentContext<PageState> ctx) {
  final List<ToDoState> initToDos = <ToDoState>[
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    ),
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    ),
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    ),

    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    ),
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    ),
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    ),
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    ),
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    ),
    ToDoState(
      uniqueId: '0',
      title: 'Hello world',
      desc: 'Learn how to program.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '1',
      title: 'Hello Flutter',
      desc: 'Learn how to build a flutter application.',
      isDone: true,
    ),
    ToDoState(
      uniqueId: '2',
      title: 'How Fish Redux',
      desc: 'Learn how to use Fish Redux in a flutter application.',
      isDone: false,
    )
  ];

  ctx.dispatch(Action('initToDos', payload: initToDos));
}

void _onAdd(Action action) {
  // Navigator.of(ctx.context)
  //     .pushNamed('todo_edit', arguments: null)
  //     .then((dynamic toDo) {
  //   if (toDo != null &&
  //       (toDo.title?.isNotEmpty == true || toDo.desc?.isNotEmpty == true)) {
  //     ctx.dispatch(list_action.ToDoListActionCreator.add(toDo));
  //   }
  // });
}

Reducer<PageState> buildReducer() {
  return asReducer(
    <Object, Reducer<PageState>>{'initToDos': _initToDosReducer},
  );
}

PageState _initToDosReducer(PageState state, Action action) {
  final List<ToDoState> toDos = action.payload ?? <ToDoState>[];
  final PageState newState = state.clone();
  newState.toDos = toDos;
  return newState;
}