import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;
import 'package:flutter_test/flutter_test.dart';
import 'package:test_widgets/static_flow_adapter/action.dart';
import 'package:test_widgets/static_flow_adapter/component.dart';
import 'package:test_widgets/static_flow_adapter/page.dart';
import 'package:test_widgets/static_flow_adapter/state.dart';
import 'package:test_widgets/static_flow_adapter/static_flow_adapter.dart';
import 'package:test_widgets/test_base.dart';

import '../instrument.dart';
import '../track.dart';

class ToDoComponentInstrument extends TestComponent<Todo> {
  ToDoComponentInstrument(final Track track, int index,
      {bool hasReducer = true})
      : super(
            view: instrumentView<Todo>(toDoView,
                (Todo state, Dispatch dispatch, ViewService viewService) {
              track.append('toDo$index-build', state.clone());
            }),
            reducer: hasReducer
                ? instrumentReducer<Todo>(toDoReducer,
                    change: (Todo state, Action action) {
                    track.append('toDo$index-onReduce', state.clone());
                  })
                : null,
            effect: instrumentEffect<Todo>(toDoEffect,
                (Action action, Get<Todo> getState) {
              if (action.type == ToDoAction.onEdit) {
                track.append('toDo$index-onEdit', getState().clone());
              } else if (action.type == ToDoAction.broadcast) {
                track.append('toDo$index-onToDoBroadcast', getState().clone());
              }
            }),
            shouldUpdate: shouldUpdate);
}

class ToDoAdapterInstrument extends TestAdapter<Todo> {
  ToDoAdapterInstrument(final Track track, int index, {bool hasReducer = true})
      : super(
          adapter: asAdapter(instrumentView<Todo>(toDoView,
              (Todo state, Dispatch dispatch, ViewService viewService) {
            track.append('toDo$index-build', state.clone());
          })),
          reducer: hasReducer
              ? instrumentReducer<Todo>(toDoReducer,
                  change: (Todo state, Action action) {
                  track.append('toDo$index-onReduce', state.clone());
                })
              : null,
          effect: instrumentEffect<Todo>(toDoEffect,
              (Action action, Get<Todo> getState) {
            if (action.type == ToDoAction.onEdit) {
              track.append('toDo$index-onEdit', getState().clone());
            } else if (action.type == ToDoAction.broadcast) {
              track.append('toDo$index-onToDoBroadcast', getState().clone());
            }
          }),
        );
}

class Component0 extends ToDoComponentInstrument {
  Component0(final Track track) : super(track, 0);
}

class Adapter1 extends ToDoAdapterInstrument {
  Adapter1(final Track track) : super(track, 1);
}

class Component2 extends ToDoComponentInstrument {
  Component2(final Track track) : super(track, 2, hasReducer: false);
}

class Adapter3 extends ToDoAdapterInstrument {
  Adapter3(final Track track) : super(track, 3, hasReducer: false);
}

Dependencies<ToDoList> toDoListDependencies(final Track track) =>
    Dependencies<ToDoList>(
        adapter: NoneConn<ToDoList>() +
            TestStaticFlowAdapter<ToDoList>(
                slots: [
                  ConnOp<ToDoList, Todo>(
                          get: (ToDoList toDoList) => toDoList.list[0],
                          set: (ToDoList toDoList, Todo toDo) =>
                              toDoList.list[0] = toDo) +
                      Component0(track),
                  ConnOp<ToDoList, Todo>(
                          get: (ToDoList toDoList) => toDoList.list[1],
                          set: (ToDoList toDoList, Todo toDo) =>
                              toDoList.list[1] = toDo) +
                      Adapter1(track),
                  ConnOp<ToDoList, Todo>(
                          get: (ToDoList toDoList) => toDoList.list[2],
                          set: (ToDoList toDoList, Todo toDo) =>
                              toDoList.list[2] = toDo) +
                      Component2(track),
                  ConnOp<ToDoList, Todo>(
                          get: (ToDoList toDoList) => toDoList.list[3],
                          set: (ToDoList toDoList, Todo toDo) =>
                              toDoList.list[3] = toDo) +
                      Adapter3(track)
                ],
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
                  }
                })));

void main() {
  group('static_flow_adapter', () {
    test('create', () {
      final Track track = Track();
      final TestComponent<Todo> component = ToDoComponentInstrument(track, 0);
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
              dependencies: toDoListDependencies(track))
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

      expect(track.countOfTag('page-build'), 1);
      expect(track.countOfTag('toDo0-build'), 1);
      expect(track.countOfTag('toDo1-build'), 1);
      expect(track.countOfTag('toDo2-build'), 1);
      expect(track.countOfTag('toDo3-build'), 1);

      track.reset();
    });

    testWidgets('reducer', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('page-build', state.clone());
              }),
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

      expect(find.text('desc-2'), findsNothing);
      expect(find.byKey(const ValueKey<String>('remove-2')), findsNothing);
      expect(find.text('title-2'), findsNothing);

      await tester.tap(find.byKey(const ValueKey<String>('remove-3')));
      await tester.pump();

      expect(find.text('desc-3'), findsNothing);
      expect(find.byKey(const ValueKey<String>('remove-3')), findsNothing);
      expect(find.text('title-3'), findsNothing);

//      ToDoList mockState = ToDoList.fromMap(pageInitParams);
//      expect(
//          track,
//          Track.pins([
//            Pin('page-build', mockState.clone()),
//            Pin('toDo0-build', mockState.list[0].clone()),
//            Pin('toDo1-build', mockState.list[1].clone()),
//            Pin('toDo2-build', mockState.list[2].clone()),
//            Pin('toDo3-build', mockState.list[3].clone()),
//            Pin('toDo0-onReduce', () {
//              mockState.list[0] = toDoReducer(mockState.list[0],
//                      Action(ToDoAction.markDone, payload: mockState.list[0]))
//                  .clone();
//              return mockState.list[0].clone();
//            }),
//            Pin('page-build', mockState.clone()),
//            Pin('toDo0-build', mockState.list[0].clone()),
//            Pin('toDo1-build', mockState.list[1].clone()),
//            Pin('toDo3-build', mockState.list[3].clone()),
//            Pin('toDo1-onReduce', () {
//              mockState.list[1] = toDoReducer(mockState.list[1],
//                      Action(ToDoAction.markDone, payload: mockState.list[1]))
//                  .clone();
//              return mockState.list[1].clone();
//            }),
//            Pin('page-build', mockState.clone()),
//            Pin('toDo1-build', mockState.list[1].clone()),
//            Pin('toDo3-build', mockState.list[3].clone()),
//            Pin('adapter-onReduce', () {
//              mockState = toDoListReducer(mockState,
//                  Action(ToDoListAction.remove, payload: mockState.list[2]));
//              return mockState.clone();
//            }),
//            Pin('page-build', mockState.clone()),
//            Pin('toDo2-build', mockState.list[2].clone()),
//            Pin('adapter-onReduce', () {
//              mockState = toDoListReducer(mockState,
//                  Action(ToDoListAction.remove, payload: mockState.list[3]));
//              return mockState.clone();
//            }),
//            Pin('page-build', mockState.clone()),
//            Pin('toDo3-build', mockState.list[3].clone()),
//          ]));
    });

    testWidgets('effect', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: initState,
              view: instrumentView<ToDoList>(pageView,
                  (ToDoList state, Dispatch dispatch, ViewService viewService) {
                track.append('page-build', state.clone());
              }),
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams)));

      await tester.tap(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump();

      expect(find.text('desc-0-effect'), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('edit-1')));
      await tester.pump();

      expect(find.text('desc-1-effect'), findsNWidgets(1));

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('page-build', mockState.clone()),
            Pin('toDo0-build', mockState.list[0].clone()),
            Pin('toDo1-build', mockState.list[1].clone()),
            Pin('toDo2-build', mockState.list[2].clone()),
            Pin('toDo3-build', mockState.list[3].clone()),
            Pin('toDo0-onEdit', mockState.list[0].clone()),
            Pin('toDo0-onReduce', () {
              String desc = '${mockState.list[0].desc}-effect';
              mockState.list[0] = mockState.list[0].clone()..desc = desc;
              return mockState.list[0].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo0-build', mockState.list[0].clone()),
            // Pin('toDo1-build', mockState.list[1].clone()),
            // Pin('toDo3-build', mockState.list[3].clone()),
            Pin('toDo1-onEdit', mockState.list[1].clone()),
            Pin('toDo1-onReduce', () {
              String desc = '${mockState.list[1].desc}-effect';
              mockState.list[1] = mockState.list[1].clone()..desc = desc;
              return mockState.list[1].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo1-build', mockState.list[1].clone()),
            // Pin('toDo3-build', mockState.list[3].clone()),
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
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams)));

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('mark-0')));
      await tester.pump(Duration(seconds: 1));

      print(track);

      expect(track.countOfTag('toDo0-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo1-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo2-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo3-onToDoBroadcast'), 1);
      expect(track.countOfTag('adapter-onToDoBroadcast'), 1);

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('mark-1')));
      await tester.pump(Duration(seconds: 1));

      expect(track.countOfTag('toDo0-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo1-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo2-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo3-onToDoBroadcast'), 1);
      expect(track.countOfTag('adapter-onToDoBroadcast'), 1);
    });
  });
}
