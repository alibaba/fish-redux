import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;
import 'package:flutter_test/flutter_test.dart';
import 'package:test_widgets/dynamic_flow_adapter/action.dart';
import 'package:test_widgets/dynamic_flow_adapter/component.dart';
import 'package:test_widgets/dynamic_flow_adapter/dynamic_flow_adapter.dart';
import 'package:test_widgets/dynamic_flow_adapter/page.dart';
import 'package:test_widgets/dynamic_flow_adapter/state.dart';
import 'package:test_widgets/test_base.dart';

import '../instrument.dart';
import '../track.dart';

class ToDoComponentInstrument extends TestComponent<Todo> {
  ToDoComponentInstrument(final Track track)
      : super(
          view: instrumentView<Todo>(toDoView,
              (Todo state, Dispatch dispatch, ViewService viewService) {
            track.append('toDo-build', state.clone());
          }),
          reducer: instrumentReducer<Todo>(toDoReducer,
              change: (Todo state, Action action) {
            track.append('toDo-onReduce', state.clone());
          }),
          effect: instrumentEffect<Todo>(toDoEffect,
              (Action action, Get<Todo> getState) {
            if (action.type == ToDoAction.onEdit) {
              track.append('toDo-onEdit', getState().clone());
            } else if (action.type == ToDoAction.broadcast) {
              track.append('toDo-onToDoBroadcast', getState().clone());
            } else if (action.type == ToDoListAction.broadcast) {
              track.append('toDo-onPageBroadcast', getState().clone());
            }
          }),
          shouldUpdate: shouldUpdate,
          key: (Todo toDo) => GlobalObjectKey(toDo.id),
        );
}

class ToDoComponentNoReducer extends TestComponent<Todo> {
  ToDoComponentNoReducer(final Track track)
      : super(
          view: instrumentView<Todo>(toDoView,
              (Todo state, Dispatch dispatch, ViewService viewService) {
            track.append('toDo-build', state.clone());
          }),
          effect: instrumentEffect<Todo>(toDoEffect,
              (Action action, Get<Todo> getState) {
            if (action.type == ToDoAction.onEdit) {
              track.append('toDo-onEdit', getState().clone());
            } else if (action.type == ToDoAction.broadcast) {
              track.append('toDo-onToDoBroadcast', getState().clone());
            } else if (action.type == ToDoListAction.broadcast) {
              track.append('toDo-onPageBroadcast', getState().clone());
            }
          }),
          shouldUpdate: shouldUpdate,
          key: (Todo toDo) => GlobalObjectKey(toDo.id),
        );
}

Dependencies<ToDoList> toDoListDependencies(final Track track,
        {bool noReducer = false}) =>
    Dependencies<ToDoList>(
        adapter: NoneConn<ToDoList>() +
            TestDynamicFlowAdapter<ToDoList>(
                pool: <String, AbstractLogic<Todo>>{
                  'toDo': ToDoComponentInstrument(track),
                  'toDoNoReducer': ToDoComponentNoReducer(track),
                },
                connector: ConnOp<ToDoList, List<ItemBean>>(
                    get: (ToDoList toDoList) => toDoList.list
                        .map<ItemBean>((Todo toDo) => noReducer
                            ? ItemBean('toDoNoReducer', toDo)
                            : ItemBean('toDo', toDo))
                        .toList(),
                    set: (ToDoList toDoList, List<ItemBean> beans) {
                      toDoList.list.clear();
                      toDoList.list.addAll(beans
                          .map<Todo>((ItemBean bean) => bean.data)
                          .toList());
                    }),
                reducer: instrumentReducer<ToDoList>(toDoListReducer,
                    change: (ToDoList state, Action action) {
                  track.append('adapter-onReduce', state.clone());
                }),
                effect: instrumentEffect<ToDoList>(toDoListEffect,
                    (Action action, Get<ToDoList> getState) {
                  if (action.type == ToDoListAction.onAdd) {
                    track.append('adapter-onAdd', getState().clone());
                  } else if (action.type == ToDoAction.broadcast) {
                    track.append('adapter-onToDoBroadcast', getState().clone());
                  } else if (action.type == ToDoListAction.broadcast) {
                    track.append('adapter-onPageBroadcast', getState().clone());
                  }
                })));

void main() {
  group('dynamic_flow_adapter', () {
    test('create', () {
      final Track track = Track();
      final TestComponent<Todo> component = ToDoComponentInstrument(track);
      expect(component, isNotNull);

      Widget page = TestPage<ToDoList, Map>(
              initState: initState,
              view: pageView,
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams);
      expect(page, isNotNull);
    });

    testWidgets('build', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('page-build', state.clone());
              }),
              reducer: toDoListReducer,
              effect: toDoListEffect,
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams)));

      expect(find.byKey(const ValueKey<String>('Add')), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-0')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-0')), findsOneWidget);
      expect(find.text('desc-0'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-0')), findsOneWidget);
      expect(find.text('title-0'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-1')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-1')), findsOneWidget);
      expect(find.text('desc-1'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-1')), findsOneWidget);
      expect(find.text('title-1'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-2')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-2')), findsOneWidget);
      expect(find.text('desc-2'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-2')), findsOneWidget);
      expect(find.text('title-2'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-3')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-3')), findsOneWidget);
      expect(find.text('desc-3'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-3')), findsOneWidget);
      expect(find.text('title-3'), findsOneWidget);

      expect(find.text('mark\ndone'), findsNWidgets(3));
      expect(find.text('done'), findsOneWidget);

      expect(track.countOfTag('page-build'), 1);
      expect(track.countOfTag('toDo-build'), 4);
    });

    testWidgets('build-noReducer', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('page-build', state.clone());
              }),
              reducer: toDoListReducer,
              effect: toDoListEffect,
              dependencies: toDoListDependencies(track, noReducer: true))
          .buildPage(pageInitParams)));

      expect(find.byKey(const ValueKey<String>('Add')), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-0')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-0')), findsOneWidget);
      expect(find.text('desc-0'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-0')), findsOneWidget);
      expect(find.text('title-0'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-1')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-1')), findsOneWidget);
      expect(find.text('desc-1'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-1')), findsOneWidget);
      expect(find.text('title-1'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-2')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-2')), findsOneWidget);
      expect(find.text('desc-2'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-2')), findsOneWidget);
      expect(find.text('title-2'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-3')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-3')), findsOneWidget);
      expect(find.text('desc-3'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-3')), findsOneWidget);
      expect(find.text('title-3'), findsOneWidget);

      expect(find.text('mark\ndone'), findsNWidgets(3));
      expect(find.text('done'), findsOneWidget);

      expect(track.countOfTag('page-build'), 1);
      expect(track.countOfTag('toDo-build'), 4);
    });

    testWidgets('reducer', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('page-build', state.clone());
              }),
              effect: pageEffect,
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams)));

      await tester.tap(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump();

      expect(find.text('mark\ndone'), findsNWidgets(2));
      expect(find.text('done'), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey<String>('mark-1')));
      await tester.pump();

      expect(find.text('mark\ndone'), findsNWidgets(1));
      expect(find.text('done'), findsNWidgets(3));

      await tester.tap(find.byKey(const ValueKey<String>('remove-2')));
      await tester.pump();

      expect(find.text('title-2'), findsNothing);
      expect(find.text('desc-2'), findsNothing);

      await tester.tap(find.byKey(const ValueKey<String>('remove-3')));
      await tester.pump();

      expect(find.text('title-3'), findsNothing);
      expect(find.text('desc-3'), findsNothing);

      print(track);

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', mockState.list[0].clone()),
            Pin('toDo-build', mockState.list[1].clone()),
            Pin('toDo-build', mockState.list[2].clone()),
            Pin('toDo-build', mockState.list[3].clone()),
            Pin('toDo-onReduce', () {
              mockState.list[0] = toDoReducer(mockState.list[0],
                  Action(ToDoAction.markDone, payload: mockState.list[0]));
              return mockState.list[0].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', mockState.list[0].clone()),
            Pin('toDo-onReduce', () {
              mockState.list[1] = toDoReducer(mockState.list[1],
                  Action(ToDoAction.markDone, payload: mockState.list[1]));
              return mockState.list[1].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', mockState.list[1].clone()),
            Pin('adapter-onReduce', () {
              mockState = toDoListReducer(mockState,
                  Action(ToDoListAction.remove, payload: mockState.list[2]));
              return mockState.clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('adapter-onReduce', () {
              mockState = toDoListReducer(mockState,
                  Action(ToDoListAction.remove, payload: mockState.list[2]));
              return mockState.clone();
            }),
            Pin('page-build', mockState.clone()),
          ]));
    });

    testWidgets('effect', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('page-build', state.clone());
              }),
              effect: pageEffect,
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams)));

      await tester.tap(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump();

      expect(find.text('desc-0-effect'), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('edit-1')));
      await tester.pump();

      expect(find.text('desc-1-effect'), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump();

      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(1));

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', mockState.list[0].clone()),
            Pin('toDo-build', mockState.list[1].clone()),
            Pin('toDo-build', mockState.list[2].clone()),
            Pin('toDo-build', mockState.list[3].clone()),
            Pin('toDo-onEdit', mockState.list[0].clone()),
            Pin('toDo-onReduce', () {
              final Todo toDo = mockState.list[0].clone();
              toDo.desc = '${toDo.desc}-effect';
              mockState.list[0] =
                  toDoReducer(toDo, Action(ToDoAction.edit, payload: toDo));
              return mockState.list[0].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', mockState.list[0].clone()),
            Pin('toDo-onEdit', mockState.list[1].clone()),
            Pin('toDo-onReduce', () {
              final Todo toDo = mockState.list[1].clone();
              toDo.desc = '${toDo.desc}-effect';
              mockState.list[1] =
                  toDoReducer(toDo, Action(ToDoAction.edit, payload: toDo));
              return mockState.list[1].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', mockState.list[1].clone()),
            Pin('adapter-onAdd', mockState.clone()),
            Pin('adapter-onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', Todo.mock()),
          ]));
    });

    testWidgets('effect-noReducer', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('page-build', state.clone());
              }),
              effect: pageEffect,
              dependencies: toDoListDependencies(track, noReducer: true))
          .buildPage(pageInitParams)));

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump();

      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(1));

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', mockState.list[0].clone()),
            Pin('toDo-build', mockState.list[1].clone()),
            Pin('toDo-build', mockState.list[2].clone()),
            Pin('toDo-build', mockState.list[3].clone()),
            Pin('adapter-onAdd', mockState.clone()),
            Pin('adapter-onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo-build', Todo.mock()),
          ]));
    });

    testWidgets('broadcast', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('page-build', state.clone());
              }),
              effect: pageEffect,
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams)));

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump(Duration(seconds: 1));

      print(track);

      expect(track.countOfTag('toDo-onToDoBroadcast'), 4);
      expect(track.countOfTag('adapter-onToDoBroadcast'), 1);

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('Add')));
      await tester.pump(Duration(seconds: 1));

      expect(track.countOfTag('toDo-onToDoBroadcast'), 4);
      expect(track.countOfTag('adapter-onToDoBroadcast'), 1);

      await tester.tap(find.byKey(const ValueKey<String>('remove-1')));
      await tester.pump();

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('Add')));
      await tester.pump(Duration(seconds: 1));

      expect(track.countOfTag('toDo-onToDoBroadcast'), 3);
      expect(track.countOfTag('adapter-onToDoBroadcast'), 1);

      await tester.tap(find.byKey(const ValueKey<String>('remove-2')));
      await tester.pump();

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('Add')));
      await tester.pump(Duration(seconds: 1));

      expect(track.countOfTag('toDo-onToDoBroadcast'), 2);
      expect(track.countOfTag('adapter-onToDoBroadcast'), 1);

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump();

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('Add')));
      await tester.pump(Duration(seconds: 1));

      expect(track.countOfTag('toDo-onToDoBroadcast'), 3);
      expect(track.countOfTag('adapter-onToDoBroadcast'), 1);
    });
  });
}
