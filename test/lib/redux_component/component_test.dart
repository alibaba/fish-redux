import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;
import 'package:flutter_test/flutter_test.dart';
import 'package:test_widgets/component/action.dart';
import 'package:test_widgets/component/component.dart';
import 'package:test_widgets/component/page.dart';
import 'package:test_widgets/component/state.dart';
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
              } else if (action.type == ToDoListAction.broadcast) {
                track.append('toDo$index-onPageBroadcast', getState().clone());
              }
            }),
            shouldUpdate: shouldUpdate);
}

class Component0 extends ToDoComponentInstrument {
  Component0(final Track track) : super(track, 0);
}

class Component1 extends ToDoComponentInstrument {
  Component1(final Track track) : super(track, 1);
}

class Component2 extends ToDoComponentInstrument {
  Component2(final Track track) : super(track, 2);
}

class Component3 extends ToDoComponentInstrument {
  Component3(final Track track) : super(track, 3, hasReducer: false);
}

Dependencies<ToDoList> toDoListDependencies(final Track track) =>
    Dependencies<ToDoList>(slots: {
      'toDo0': ConnOp<ToDoList, Todo>(
              get: (ToDoList toDoList) => toDoList.list[0],
              set: (ToDoList toDoList, Todo toDo) => toDoList.list[0] = toDo) +
          Component0(track),
      'toDo1': ConnOp<ToDoList, Todo>(
              get: (ToDoList toDoList) => toDoList.list[1],
              set: (ToDoList toDoList, Todo toDo) => toDoList.list[1] = toDo) +
          Component1(track),
      'toDo2': ConnOp<ToDoList, Todo>(
              get: (ToDoList toDoList) => toDoList.list[2],
              set: (ToDoList toDoList, Todo toDo) => toDoList.list[2] = toDo) +
          Component2(track),
      'toDo3': ConnOp<ToDoList, Todo>(
              get: (ToDoList toDoList) => toDoList.list[3],
              set: (ToDoList toDoList, Todo toDo) => toDoList.list[3] = toDo) +
          Component3(track),
    });

Widget pageView(
  ToDoList state,
  Dispatch dispatch,
  ViewService viewService,
) {
  return Column(
    children: <Widget>[
      Expanded(
          child: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return viewService.buildComponent('toDo0');
          } else if (index == 1) {
            return viewService.buildComponent('toDo1');
          } else if (index == 2) {
            return viewService.buildComponent('toDo2');
          } else if (index == 3) {
            return viewService.buildComponent('toDo3');
          } else {
            final Todo toDo = state.list[index];
            return Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              color: Colors.grey,
              child: Text(toDo.desc),
              alignment: AlignmentDirectional.center,
            );
          }
        },
        itemCount: state.list.length,
      )),
      Row(
        children: <Widget>[
          Expanded(
              child: GestureDetector(
            child: Container(
              key: const ValueKey('Add'),
              height: 68.0,
              color: Colors.green,
              alignment: AlignmentDirectional.center,
              child: const Text('Add'),
            ),
            onTap: () {
              print('dispatch Add');
              dispatch(const Action(ToDoListAction.onAdd));
            },
            onLongPress: () {
              print('dispatch broadcast');
              dispatch(const Action(ToDoListAction.onBroadcast));
            },
          )),
        ],
      )
    ],
  );
}

void main() {
  group('component', () {
    test('create', () {
      final TestComponent<Todo> component = TestComponent<Todo>(
          view: toDoView, wrapper: (child) => ComponentWrapper(child));
      expect(component, isNotNull);

      /// TODO
      final Widget componentWidget = component.buildComponent(
        createBatchStore<Todo>(Todo.mock(), null),
        () => Todo.mock(),
        enhancer: EnhancerDefault<Object>(),
        bus: DispatchBusDefault(),
      );
      expect(componentWidget, isNotNull);

      expect(
          const TypeMatcher<ComponentWrapper>().check(componentWidget), isTrue);
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
              reducer: instrumentReducer<ToDoList>(toDoListReducer,
                  change: (ToDoList state, Action action) {
                track.append('page-onReduce', state.clone());
              }),
              effect: instrumentEffect<ToDoList>(toDoListEffect,
                  (Action action, Get<ToDoList> getState) {
                if (action.type == ToDoListAction.onAdd) {
                  track.append('page-onAdd', getState().clone());
                }
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

      expect(find.text('removed'), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('remove-3')));
      await tester.pump();

      expect(find.text('removed'), findsNWidgets(2));

      ToDoList mockState = ToDoList.fromMap(pageInitParams);
      expect(
          track,
          Track.pins([
            Pin('page-build', mockState.clone()),
            Pin('toDo0-build', mockState.list[0].clone()),
            Pin('toDo1-build', mockState.list[1].clone()),
            Pin('toDo2-build', mockState.list[2].clone()),
            Pin('toDo3-build', mockState.list[3].clone()),
            Pin('toDo0-onReduce', () {
              mockState.list[0] = mockState.list[0].clone()..isDone = true;
              return mockState.list[0].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo0-build', mockState.list[0].clone()),
            Pin('toDo1-onReduce', () {
              mockState.list[1] = mockState.list[1].clone()..isDone = true;
              return mockState.list[1].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo1-build', mockState.list[1].clone()),
            Pin('page-onReduce', () {
              mockState.list[2] = mockState.list[2].clone()..desc = 'removed';
              return mockState.clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo2-build', mockState.list[2].clone()),
            Pin('page-onReduce', () {
              mockState.list[3] = mockState.list[3].clone()..desc = 'removed';
              return mockState.clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo3-build', mockState.list[3].clone()),
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
              reducer: instrumentReducer<ToDoList>(toDoListReducer,
                  change: (ToDoList state, Action action) {
                track.append('page-onReduce', state.clone());
              }),
              effect: instrumentEffect<ToDoList>(toDoListEffect,
                  (Action action, Get<ToDoList> getState) {
                if (action.type == ToDoListAction.onAdd) {
                  track.append('page-onAdd', getState().clone());
                }
              }),
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

      await tester.tap(find.byKey(const ValueKey<String>('Add')));
      await tester.pump();

      expect(find.text('desc-mock', skipOffstage: false), findsNWidgets(2));

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
            Pin('toDo1-onEdit', mockState.list[1].clone()),
            Pin('toDo1-onReduce', () {
              String desc = '${mockState.list[1].desc}-effect';
              mockState.list[1] = mockState.list[1].clone()..desc = desc;
              return mockState.list[1].clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('toDo1-build', mockState.list[1].clone()),
            Pin('page-onAdd', mockState.clone()),
            Pin('page-onReduce', () {
              mockState.list.add(Todo.mock());
              return mockState.clone();
            }),
            Pin('page-build', mockState.clone()),
            Pin('page-onAdd', mockState.clone()),
            Pin('page-onReduce', () {
              mockState.list.add(Todo.mock());
              return mockState.clone();
            }),
            Pin('page-build', mockState.clone()),
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
              reducer: instrumentReducer<ToDoList>(toDoListReducer,
                  change: (ToDoList state, Action action) {
                track.append('page-onReduce', state.clone());
              }),
              effect: instrumentEffect<ToDoList>(toDoListEffect,
                  (Action action, Get<ToDoList> getState) {
                if (action.type == ToDoListAction.onAdd) {
                  track.append('page-onAdd', getState().clone());
                } else if (action.type == ToDoAction.broadcast) {
                  track.append('page-onToDoBroadcast', getState().clone());
                } else if (action.type == ToDoListAction.broadcast) {
                  track.append('page-onPageBroadcast', getState().clone());
                }
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
      expect(track.countOfTag('page-onToDoBroadcast'), 1);

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('mark-1')));
      await tester.pump(Duration(seconds: 1));

      expect(track.countOfTag('toDo0-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo1-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo2-onToDoBroadcast'), 1);
      expect(track.countOfTag('toDo3-onToDoBroadcast'), 1);
      expect(track.countOfTag('page-onToDoBroadcast'), 1);

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('Add')));
      await tester.pump(Duration(seconds: 1));

      expect(track.countOfTag('toDo0-onPageBroadcast'), 1);
      expect(track.countOfTag('toDo1-onPageBroadcast'), 1);
      expect(track.countOfTag('toDo2-onPageBroadcast'), 1);
      expect(track.countOfTag('toDo3-onPageBroadcast'), 1);
      expect(track.countOfTag('page-onPageBroadcast'), 1);

      track.reset();
      await tester.longPress(find.byKey(const ValueKey<String>('Add')));
      await tester.pump(Duration(seconds: 1));

      expect(track.countOfTag('toDo0-onPageBroadcast'), 1);
      expect(track.countOfTag('toDo1-onPageBroadcast'), 1);
      expect(track.countOfTag('toDo2-onPageBroadcast'), 1);
      expect(track.countOfTag('toDo3-onPageBroadcast'), 1);
      expect(track.countOfTag('page-onPageBroadcast'), 1);
    });
  });
}
