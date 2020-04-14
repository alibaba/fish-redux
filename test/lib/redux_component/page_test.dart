import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;
import 'package:flutter_test/flutter_test.dart';
import 'package:test_widgets/page/action.dart';
import 'package:test_widgets/page/page.dart';
import 'package:test_widgets/page/state.dart';
import 'package:test_widgets/test_base.dart';

import '../instrument.dart';
import '../track.dart';

void main() {
  group('page', () {
    test('create', () {
      TestPage<ToDoList, Map> page = TestPage<ToDoList, Map>(
          initState: initState,
          view: toDoListView,
          wrapper: (Widget child) => PageWrapper(child));
      expect(page, isNotNull);

      /// TODO
      final Widget pageWidget = page.buildPage(pageInitParams);
      expect(pageWidget, isNotNull);

      expect(const TypeMatcher<PageWrapper>().check(pageWidget), isTrue);
      //expect(pageWidget, TypeMatcher<PageWrapper>());
    });

    testWidgets('build', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
          initState: instrumentInitState<ToDoList, Map>(initState, pre: (map) {
            track.append('initState', map);
          }),
          view: instrumentView<ToDoList>(toDoListView,
              (ToDoList state, Dispatch dispatch, ViewService viewService) {
            track.append('build', state.clone());
          })).buildPage(pageInitParams)));

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

      expect(
          track,
          Track.pins([
            Pin('initState', pageInitParams),
            Pin('build', ToDoList.fromMap(pageInitParams))
          ]));
    });

    testWidgets('reducer', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
          initState: instrumentInitState<ToDoList, Map>(initState, pre: (map) {
            track.append('initState', map);
          }),
          view: instrumentView<ToDoList>(toDoListView,
              (ToDoList state, Dispatch dispatch, ViewService viewService) {
            track.append('build', state.clone());
          }),
          reducer: instrumentReducer<ToDoList>(toDoListReducer,
              suf: (ToDoList state, Action action) {
            track.append('onReduce', state.clone());
          })).buildPage(pageInitParams)));

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
            Pin('initState', pageInitParams),
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
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
          initState: instrumentInitState<ToDoList, Map>(initState, pre: (map) {
            track.append('initState', map);
          }),
          view: instrumentView<ToDoList>(toDoListView,
              (ToDoList state, Dispatch dispatch, ViewService viewService) {
            track.append('build', state.clone());
          }),
          reducer: instrumentReducer<ToDoList>(toDoListReducer,
              suf: (ToDoList state, Action action) {
            track.append('onReduce', state.clone());
          }),
          effect: instrumentEffect(toDoListEffect,
              (Action action, Get<ToDoList> getState) {
            if (action.type == ToDoListAction.onAdd) {
              track.append('onAdd', getState().clone());
            } else if (action.type == ToDoListAction.onEdit) {
              track.append('onEdit', getState().clone());
            }
          })).buildPage(pageInitParams)));

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump();

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(1));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
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
            Pin('initState', pageInitParams),
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
              Todo toDo = mockState.list.firstWhere((i) => i.id == '0');
              toDo = toDo.clone();
              toDo.desc = '${toDo.desc}-effect';
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.edit, payload: toDo));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
          ]));
    });

    testWidgets('effectAsync', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
          initState: instrumentInitState<ToDoList, Map>(initState, pre: (map) {
            track.append('initState', map);
          }),
          view: instrumentView<ToDoList>(toDoListView,
              (ToDoList state, Dispatch dispatch, ViewService viewService) {
            track.append('build', state.clone());
          }),
          reducer: instrumentReducer<ToDoList>(toDoListReducer,
              suf: (ToDoList state, Action action) {
            track.append('onReduce', state.clone());
          }),
          effect: instrumentEffect(toDoListEffectAsync,
              (Action action, Get<ToDoList> getState) {
            if (action.type == ToDoListAction.onAdd) {
              track.append('onAdd', getState().clone());
            } else if (action.type == ToDoListAction.onEdit) {
              track.append('onEdit', getState().clone());
            }
          })).buildPage(pageInitParams)));

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump(Duration(seconds: 3));

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(1));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
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
            Pin('initState', pageInitParams),
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
              Todo toDo = mockState.list.firstWhere((i) => i.id == '0');
              toDo = toDo.clone();
              toDo.desc = '${toDo.desc}-effect';
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.edit, payload: toDo));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
          ]));
    });

    testWidgets('effect', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
          initState: instrumentInitState<ToDoList, Map>(initState, pre: (map) {
            track.append('initState', map);
          }),
          view: instrumentView<ToDoList>(toDoListView,
              (ToDoList state, Dispatch dispatch, ViewService viewService) {
            track.append('build', state.clone());
          }),
          reducer: instrumentReducer<ToDoList>(toDoListReducer,
              suf: (ToDoList state, Action action) {
            track.append('onReduce', state.clone());
          }),
          effect: (Action action, Context<ToDoList> ctx) => instrumentEffect(
                  toDoListEffect, (Action action, Get<ToDoList> getState) {
                if (action.type == ToDoListAction.onAdd) {
                  track.append('onAdd', getState().clone());
                } else if (action.type == ToDoListAction.onEdit) {
                  track.append('onEdit', getState().clone());
                }
              })(action, ctx)).buildPage(pageInitParams)));

      expect(find.byKey(const ValueKey<String>('Add')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump();

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(1));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(1));

      expect(find.byKey(const ValueKey<String>('Add')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump();

      expect(find.text('title-mock', skipOffstage: false), findsNWidgets(2));
      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(2));

      expect(find.byKey(const ValueKey<String>('edit-0')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump();

      expect(find.text('title-0'), findsOneWidget);
      expect(find.text('desc-0-effect'), findsOneWidget);

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('initState', pageInitParams),
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
              Todo toDo = mockState.list.firstWhere((i) => i.id == '0');
              toDo = toDo.clone();
              toDo.desc = '${toDo.desc}-effect';
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.edit, payload: toDo));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
          ]));
    });

    testWidgets('shouldUpdate', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState:
                  instrumentInitState<ToDoList, Map>(initState, pre: (map) {
                track.append('initState', map);
              }),
              view: instrumentView<ToDoList>(toDoListView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('build', state.clone());
              }),
              reducer: instrumentReducer<ToDoList>(toDoListReducer,
                  suf: (ToDoList state, Action action) {
                track.append('onReduce', state.clone());
              }),
              effect: (Action action, Context<ToDoList> ctx) =>
                  instrumentEffect<ToDoList>(toDoListEffect,
                      (Action action, Get<ToDoList> getState) {
                    if (action.type == ToDoListAction.onAdd) {
                      track.append('onAdd', getState().clone());
                    }
                  })(action, ctx),
              shouldUpdate: forbidRefreshUI)
          .buildPage(pageInitParams)));

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump();

      expect(find.text('title-mock'), findsNothing);
      expect(find.text('desc-mock'), findsNothing);

      await tester.tap(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump();

      expect(find.text('mark\ndone'), findsNWidgets(3));
      expect(find.text('done'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('remove-1')));
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('remove-1')), findsOneWidget);
      expect(find.text('desc-1'), findsOneWidget);
      expect(find.text('title-1'), findsOneWidget);

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('initState', pageInitParams),
            Pin('build', mockState.clone()),
            Pin('onAdd', mockState.clone()),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.add, payload: Todo.mock()));
              return mockState.clone();
            }),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState,
                  Action(ToDoListAction.markDone,
                      payload: mockState.list.firstWhere((i) => i.id == '0')));
              return mockState.clone();
            }),
            Pin('onReduce', () {
              mockState = toDoListReducer(
                  mockState,
                  Action(ToDoListAction.remove,
                      payload: mockState.list.firstWhere((i) => i.id == '1')));
              return mockState.clone();
            }),
          ]));
    });

    /// TODO
    testWidgets('middleware', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
          initState: instrumentInitState<ToDoList, Map>(initState, pre: (map) {
            track.append('initState', map);
          }),
          view: instrumentView<ToDoList>(toDoListView,
              (ToDoList state, Dispatch dispatch, ViewService viewService) {
            track.append('build', state.clone());
          }),
          reducer: instrumentReducer<ToDoList>(toDoListReducer,
              suf: (ToDoList state, Action action) {
            track.append('onReduce', state.clone());
          }),
          effect: toDoListEffect,
          middleware: <Middleware<ToDoList>>[
            instrumentMiddleware<ToDoList>(toDoListMiddleware,
                pre: (action, getState) {
              if (action.type == ToDoListAction.middlewareEdit) {
                track.append('onMiddleware', getState().clone());
              }
            })
          ]).buildPage(pageInitParams)));

      expect(find.byKey(const ValueKey<String>('edit-0')), findsOneWidget);
      await tester.longPress(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump();

      expect(find.text('desc-0-middleware'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('edit-0')), findsOneWidget);
      await tester.longPress(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump();

      expect(find.text('desc-0-middleware-middleware'), findsOneWidget);

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('initState', pageInitParams),
            Pin('build', mockState.clone()),
            Pin('onMiddleware', mockState.clone()),
            Pin('onReduce', mockState.clone()),
            Pin('onReduce', () {
              Todo toDo = mockState.list.firstWhere((i) => i.id == '0');
              toDo = toDo.clone();
              toDo.desc = '${toDo.desc}-middleware';
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.edit, payload: toDo));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
            Pin('onMiddleware', mockState.clone()),
            Pin('onReduce', mockState.clone()),
            Pin('onReduce', () {
              Todo toDo = mockState.list.firstWhere((i) => i.id == '0');
              toDo = toDo.clone();
              toDo.desc = '${toDo.desc}-middleware';
              mockState = toDoListReducer(
                  mockState, Action(ToDoListAction.edit, payload: toDo));
              return mockState.clone();
            }),
            Pin('build', mockState.clone()),
          ]));
    });

    // testWidgets('error', (WidgetTester tester) async {
    //   final Track track = Track();

    //   await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
    //       initState: initState,
    //       view: toDoListView,
    //       reducer: toDoListReducer,
    //       higherEffect: toDoListHigherEffect,
    //       onError: instrumentError<ToDoList>(toDoListErrorHandler, (exp, ctx) {
    //         track.append('onErr', exp);
    //       })).buildPage(pageInitParams)));

    //   await tester.tap(find.byKey(const ValueKey<String>('Error')));
    //   await tester.pump();

    //   expect(
    //       track,
    //       Track.pins([
    //         Pin('onErr', KnowException()),
    //       ]));

    //   //expect(exception, UnKnowException());
    // });

    // testWidgets('errorAsync', (WidgetTester tester) async {
    //   final Track track = Track();

    //   await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
    //       initState: initState,
    //       view: toDoListView,
    //       reducer: toDoListReducer,
    //       effect: toDoListEffectAsync,
    //       onError: instrumentError<ToDoList>(toDoListErrorHandler, (exp, ctx) {
    //         track.append('onErr', exp);
    //       })).buildPage(pageInitParams)));

    //   await tester.tap(find.byKey(const ValueKey<String>('Error')));
    //   await tester.pump(Duration(seconds: 3));

    //   expect(
    //       track,
    //       Track.pins([
    //         Pin('onErr', KnowException()),
    //       ]));

    //   //expect(exception, UnKnowException());
    // });
  });
}
