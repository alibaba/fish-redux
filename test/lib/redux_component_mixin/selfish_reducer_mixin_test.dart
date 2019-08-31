import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_widgets/test_base.dart';

enum SelfishTestAction { add }

class SelfishTestState
    implements Cloneable<SelfishTestState>, Comparison<SelfishTestState> {
  int businessId;

  int count;

  SelfishTestState({this.businessId, this.count});

  @override
  SelfishTestState clone() {
    return SelfishTestState(businessId: businessId, count: count);
  }

  @override
  bool compare(SelfishTestState other) {
    return businessId == other.businessId;
  }
}

class ListSelfishTestState implements Cloneable<ListSelfishTestState> {
  List<SelfishTestState> data;

  ListSelfishTestState(this.data);

  @override
  ListSelfishTestState clone() {
    return ListSelfishTestState(data);
  }
}
class SelfishTestComponent extends TestComponent<SelfishTestState> with SelfishReducerMixin{

  SelfishTestComponent():super(
      view: (state, dispatch, viewService) {
        return Row(
          children: <Widget>[
            FlatButton(
              key: ValueKey<String>('add-${state.businessId}'),
              onPressed: () {
                dispatch(SelfishAction(SelfishTestAction.add));
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                height: 28.0,
                color: Colors.yellow,
                child: Text(
                  'desc-${state.count}',
                  style: TextStyle(fontSize: 16.0),
                ),
                alignment: AlignmentDirectional.centerStart,
              ),
            ),
          ],
        );
      }, reducer: (SelfishTestState state, Action action) {
    if (action.type == SelfishTestAction.add) {
      return state.clone()..count += 1;
    }
    return state;
  }
  );
}


ListSelfishTestState initState(Map _) => ListSelfishTestState([
      SelfishTestState(businessId: 1, count: 0),
      SelfishTestState(businessId: 2, count: 0),
      SelfishTestState(businessId: 3, count: 0),
    ]);

Widget buildView(
    ListSelfishTestState state, Dispatch dispatch, ViewService viewService) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Expanded(
        child: viewService.buildComponent('SelfishComponent1'),
      ),
      Expanded(
        child: viewService.buildComponent('SelfishComponent2'),
      ),
      Expanded(
        child: viewService.buildComponent('SelfishComponent3'),
      ),
    ],
  );
}

void main() {
  group('selfish_reducer_mixin_test', () {
    testWidgets('reducer', (WidgetTester tester) async {
      await tester.pumpWidget(TestStub(TestPage<ListSelfishTestState, Map>(
          initState: initState,
          view: buildView,
          dependencies: Dependencies(slots: {
            'SelfishComponent1': ConnOp<ListSelfishTestState, SelfishTestState>(
                    get: (ListSelfishTestState list) => list.data[0],
                    set: (ListSelfishTestState list,
                            SelfishTestState subState) =>
                        list.data[0] = subState) +
                SelfishTestComponent(),
            'SelfishComponent2': ConnOp<ListSelfishTestState, SelfishTestState>(
                    get: (ListSelfishTestState list) => list.data[1],
                    set: (ListSelfishTestState list,
                            SelfishTestState subState) =>
                        list.data[1] = subState) +
                SelfishTestComponent(),
            'SelfishComponent3': ConnOp<ListSelfishTestState, SelfishTestState>(
                    get: (ListSelfishTestState list) => list.data[2],
                    set: (ListSelfishTestState list,
                            SelfishTestState subState) =>
                        list.data[2] = subState) +
                SelfishTestComponent(),
          })).buildPage(null)));

      expect(find.text('desc-0'), findsNWidgets(3));

      await tester.tap(find.byKey(const ValueKey<String>('add-1')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(2));
      expect(find.text('desc-1'), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('add-2')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(1));
      expect(find.text('desc-1'), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey<String>('add-3')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(0));
      expect(find.text('desc-1'), findsNWidgets(3));

      await tester.tap(find.byKey(const ValueKey<String>('add-3')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(0));
      expect(find.text('desc-1'), findsNWidgets(2));
      expect(find.text('desc-2'), findsNWidgets(1));
    });
  });
}
