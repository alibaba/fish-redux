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
  ToDoComponentInstrument(final Track track)
      : super(
            view: toDoView,
            reducer: toDoReducer,
            effect: instrumentEffect<Todo>(toDoEffect,
                (Action action, Get<Todo> getState) {
              if (action.type == ToDoAction.onEdit) {
                track.append('toDo-onEdit');
                print('toDo-onEdit');
              } else if (action.type == Lifecycle.initState) {
                track.append('toDo-initState');
                print('toDo-initState');
              } else if (action.type == Lifecycle.build) {
                track.append('toDo-build');
                print('toDo-build');
              } else if (action.type == Lifecycle.deactivate) {
                track.append('toDo-deactivate');
                print('toDo-deactivate');
              } else if (action.type == Lifecycle.didChangeDependencies) {
                track.append('toDo-didChangeDependencies');
                print('toDo-didChangeDependencies');
              } else if (action.type == Lifecycle.didUpdateWidget) {
                track.append('toDo-didUpdateWidget');
                print('toDo-didUpdateWidget');
              } else if (action.type == Lifecycle.dispose) {
                track.append('toDo-dispose');
                print('toDo-dispose');
              }
            }),
            shouldUpdate: shouldUpdate);
}

Dependencies<ToDoList> toDoListDependencies(final Track track) =>
    Dependencies<ToDoList>(slots: {
      'toDo': ConnOp<ToDoList, Todo>(
              get: (ToDoList toDoList) =>
                  toDoList.list.isNotEmpty ? toDoList.list[0] : Todo.mock(),
              set: (ToDoList toDoList, Todo toDo) => toDoList.list.isNotEmpty
                  ? toDoList.list[0] = toDo
                  : toDoList) +
          ToDoComponentInstrument(track)
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
        itemBuilder: (context, index) => viewService.buildComponent('toDo'),
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
        bus: DispatchBusDefault(),
        enhancer: EnhancerDefault<Object>(),
      );
      expect(componentWidget, isNotNull);

      expect(
          const TypeMatcher<ComponentWrapper>().check(componentWidget), isTrue);
    });

    testWidgets('cycleLife', (WidgetTester tester) async {
      final Track track = Track();

      await tester.pumpWidget(TestStub(TestPage<ToDoList, Map>(
              initState: (Map map) {
                final ToDoList toDoList = initState(map);
                final ToDoList state = ToDoList();
                state.list.add(toDoList.list[0]);
                return state;
              },
              view: pageView,
              reducer: (ToDoList state, Action action) {
                if (action.type == ToDoListAction.remove) {
                  final ToDoList newState = state.clone();
                  newState.list.clear();
                  return newState;
                } else {
                  return toDoListReducer(state, action);
                }
              },
              effect: toDoListEffect,
              dependencies: toDoListDependencies(track))
          .buildPage(pageInitParams)));

      expect(find.byKey(const ValueKey<String>('Add')), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      expect(find.byKey(const ValueKey<String>('mark-0')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('edit-0')), findsOneWidget);
      expect(find.text('desc-0'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('remove-0')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('edit-0')));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey<String>('remove-0')));
      await tester.pump();

      expect(find.byKey(const ValueKey<String>('mark-0')), findsNothing);
      expect(find.byKey(const ValueKey<String>('edit-0')), findsNothing);
      expect(find.byKey(const ValueKey<String>('remove-0')), findsNothing);

      expect(
          track,
          Track.pins([
            Pin('toDo-initState'),
            Pin('toDo-didChangeDependencies'),
            Pin('toDo-build'),
            Pin('toDo-onEdit'),
            Pin('toDo-didUpdateWidget'),
            Pin('toDo-build'),
            Pin('toDo-deactivate'),
            Pin('toDo-dispose')
          ]));
    });
  });
}
