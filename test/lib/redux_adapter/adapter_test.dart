import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;
import 'package:flutter_test/flutter_test.dart';
import 'package:test_widgets/adapter/action.dart';
import 'package:test_widgets/adapter/adapter.dart';
import 'package:test_widgets/adapter/page.dart';
import 'package:test_widgets/adapter/state.dart';
import 'package:test_widgets/test_base.dart';

import '../instrument.dart';
import '../track.dart';

void main() {
  group('adapter', () {
    test('create', () {
      TestPage<ToDoList, Map> page = TestPage<ToDoList, Map>(
          initState: initState,
          view: pageView,
          dependencies: Dependencies<ToDoList>(
              adapter: NoneConn<ToDoList>() +
                  TestAdapter<ToDoList>(
                      adapter: toDoListAdapter,
                      reducer: toDoListReducer,
                      effect: toDoListEffect)));
      expect(page, isNotNull);

      final Widget pageWidget = page.buildPage(pageInitParams);
      expect(pageWidget, isNotNull);
    });

    testWidgets('build', (WidgetTester tester) async {
      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: pageView,
              dependencies: Dependencies<ToDoList>(
                  adapter: NoneConn<ToDoList>() +
                      TestAdapter<ToDoList>(
                          adapter: toDoListAdapter,
                          reducer: toDoListReducer,
                          effect: toDoListEffect)))
          .buildPage(pageInitParams)));

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
    });

    testWidgets('reducer', (WidgetTester tester) async {
      Track track = Track();
      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('build', state.clone());
              }),
              dependencies: Dependencies<ToDoList>(
                  adapter: NoneConn<ToDoList>() +
                      TestAdapter<ToDoList>(
                          adapter: toDoListAdapter,
                          reducer: instrumentReducer<ToDoList>(toDoListReducer,
                              suf: (ToDoList state, Action action) {
                            track.append('onReduce', state.clone());
                          }),
                          effect: toDoListEffect)))
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

      expect(find.byKey(const ValueKey<String>('remove-2')), findsNothing);
      expect(find.text('desc-2'), findsNothing);
      expect(find.text('title-2'), findsNothing);

      await tester.tap(find.byKey(const ValueKey<String>('remove-3')));
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('remove-3')), findsNothing);
      expect(find.text('desc-3'), findsNothing);
      expect(find.text('title-3'), findsNothing);

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('build', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState,
                  Action(ToDoListAction.markDone,
                      payload: mockState.list.firstWhere((i) => i.id == '0')));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState,
                  Action(ToDoListAction.markDone,
                      payload: mockState.list.firstWhere((i) => i.id == '1')));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState,
                  Action(ToDoListAction.remove,
                      payload: mockState.list.firstWhere((i) => i.id == '2')));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState,
                  Action(ToDoListAction.remove,
                      payload: mockState.list.firstWhere((i) => i.id == '3')));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
          ]));
    });

    testWidgets('effect', (WidgetTester tester) async {
      Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('build', state.clone());
              }),
              dependencies: Dependencies<ToDoList>(
                  adapter: NoneConn<ToDoList>() +
                      TestAdapter<ToDoList>(
                          adapter: toDoListAdapter,
                          reducer: instrumentReducer<ToDoList>(toDoListReducer,
                              change: (ToDoList state, Action action) {
                            track.append('onReduce', state.clone());
                          }),
                          effect: instrumentEffect(toDoListEffect,
                              (Action action, Get<ToDoList> getState) {
                            if (action.type == ToDoListAction.onAdd) {
                              track.append('onAdd', getState().clone());
                            } else if (action.type == ToDoListAction.onEdit) {
                              track.append('onEdit', getState().clone());
                            }
                          }))))
          .buildPage(pageInitParams)));

      await tester.longPress(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump();

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(1));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(1));

      await tester.longPress(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump();

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(2));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump();

      expect(find.text('title-0', skipOffstage: false), findsOneWidget);
      expect(find.text('desc-0-effect', skipOffstage: false), findsOneWidget);

      ToDoList mockState = ToDoList.fromMap(pageInitParams);

      expect(
          track,
          Track.pins([
            Pin('build', mockState.clone()),
            Pin('onAdd', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onAdd', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onEdit', mockState.clone()),
            Pin('onReduce', () {
              Todo toDo = mockState.list[0].clone();
              toDo.desc = '${toDo.desc}-effect';
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.edit, payload: toDo));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
          ]));
    });

    testWidgets('effectAsync', (WidgetTester tester) async {
      Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('build', state.clone());
              }),
              dependencies: Dependencies<ToDoList>(
                  adapter: NoneConn<ToDoList>() +
                      TestAdapter<ToDoList>(
                          adapter: toDoListAdapter,
                          reducer: instrumentReducer<ToDoList>(toDoListReducer,
                              change: (ToDoList state, Action action) {
                            track.append('onReduce', state.clone());
                          }),
                          effect: instrumentEffect(toDoListEffectAsync,
                              (Action action, Get<ToDoList> getState) {
                            if (action.type == ToDoListAction.onAdd) {
                              track.append('onAdd', getState().clone());
                            } else if (action.type == ToDoListAction.onEdit) {
                              track.append('onEdit', getState().clone());
                            }
                          }))))
          .buildPage(pageInitParams)));

      await tester.longPress(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump(Duration(seconds: 3));

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(1));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(1));

      await tester.longPress(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump(Duration(seconds: 3));

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(2));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump(Duration(seconds: 3));

      expect(find.text('title-0', skipOffstage: false), findsOneWidget);
      expect(find.text('desc-0-effect', skipOffstage: false), findsOneWidget);

      ToDoList mockState = ToDoList.fromMap(pageInitParams);

      expect(
          track,
          Track.pins([
            Pin('build', mockState.clone()),
            Pin('onAdd', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onAdd', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onEdit', mockState.clone()),
            Pin('onReduce', () {
              Todo toDo = mockState.list[0].clone();
              toDo.desc = '${toDo.desc}-effect';
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.edit, payload: toDo));
              print(mockState);
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
          ]));
    });
    testWidgets('effect', (WidgetTester tester) async {
      Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('build', state.clone());
              }),
              dependencies: Dependencies<ToDoList>(
                  adapter: NoneConn<ToDoList>() +
                      TestAdapter<ToDoList>(
                          adapter: toDoListAdapter,
                          reducer: instrumentReducer<ToDoList>(toDoListReducer,
                              change: (ToDoList state, Action action) {
                            track.append('onReduce', state.clone());
                          }),
                          effect: (Action action, Context<ToDoList> ctx) =>
                              instrumentEffect(toDoListEffectAsync,
                                  (Action action, Get<ToDoList> getState) {
                                if (action.type == ToDoListAction.onAdd) {
                                  track.append('onAdd', getState().clone());
                                } else if (action.type ==
                                    ToDoListAction.onEdit) {
                                  track.append('onEdit', getState().clone());
                                }
                              })(action, ctx))))
          .buildPage(pageInitParams)));

      await tester.longPress(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump(Duration(seconds: 3));

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(1));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(1));

      await tester.longPress(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump(Duration(seconds: 3));

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(2));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump(Duration(seconds: 3));

      expect(find.text('title-0', skipOffstage: false), findsOneWidget);
      expect(find.text('desc-0-effect', skipOffstage: false), findsOneWidget);

      ToDoList mockState = ToDoList.fromMap(pageInitParams);

      expect(
          track,
          Track.pins([
            Pin('build', mockState.clone()),
            Pin('onAdd', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onAdd', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onEdit', mockState.clone()),
            Pin('onReduce', () {
              Todo toDo = mockState.list[0].clone();
              toDo.desc = '${toDo.desc}-effect';
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.edit, payload: toDo));
              print(mockState);
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
          ]));
    });
  });
}
