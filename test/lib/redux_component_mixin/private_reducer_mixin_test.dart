import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_widgets/test_base.dart';

enum PrivateTestAction { add }

class ListPrivateTestState implements Cloneable<ListPrivateTestState> {
  List<PrivateTestState> data;

  ListPrivateTestState(this.data);

  @override
  ListPrivateTestState clone() {
    return ListPrivateTestState(data);
  }
}

class PrivateTestState implements Cloneable<PrivateTestState> {
  int businessId;

  int count;

  PrivateTestState({this.businessId, this.count});

  @override
  PrivateTestState clone() {
    return PrivateTestState(businessId: businessId, count: count);
  }
}

bool _trueValueGetter()=>true;
bool _falseValueGetter()=>false;


class PrivateTestComponent extends TestComponent<PrivateTestState>
    with PrivateReducerMixin {
  @override
  bool get wantAutoConvert => autoConvert();

  ValueGetter<bool> autoConvert;

  ValueGetter<bool> useSuperCompare;

  PrivateTestComponent({this.autoConvert = _trueValueGetter, this.useSuperCompare = _falseValueGetter,ValueGetter<bool> usePrivateAction=_falseValueGetter})
      : super(view: (state, dispatch, viewService) {
          return Row(
            children: <Widget>[
              FlatButton(
                key: ValueKey<String>('add-${state.businessId}'),
                onPressed: () {
                  dispatch(usePrivateAction()?PrivateAction(PrivateTestAction.add):const Action(PrivateTestAction.add));
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
        }, reducer: (PrivateTestState state, Action action) {
          if (action.type == PrivateTestAction.add) {
            return state.clone()..count += 1;
          }
          return state;
        });

  @override
  bool compare(PrivateTestState state, dynamic other) {
    if (useSuperCompare()) {
      return super.compare(state, other);
    }
    if (other is PrivateTestState) {
      return state.businessId == other.businessId;
    } else {
      return false;
    }
  }
}

ListPrivateTestState initState(Map _) => ListPrivateTestState([
      PrivateTestState(businessId: 1, count: 0),
      PrivateTestState(businessId: 2, count: 0),
      PrivateTestState(businessId: 3, count: 0),
    ]);

Widget buildView(
    ListPrivateTestState state, Dispatch dispatch, ViewService viewService) {
  final ListAdapter adapter = viewService.buildAdapter();
  return ListView.builder(
    itemBuilder: adapter.itemBuilder,
    itemCount: adapter.itemCount,
  );

}

class PrivateDynamicFlowAdapter
    extends DynamicFlowAdapter<ListPrivateTestState> {
  PrivateDynamicFlowAdapter(
      {ValueGetter<bool> autoConvert = _trueValueGetter,
        ValueGetter<bool> useSuperCompare = _falseValueGetter,
        ValueGetter<bool> userClone = _falseValueGetter,ValueGetter<bool> usePrivateAction=_falseValueGetter})
      : super(
          pool: <String, Component<Object>>{
            'PrivateComponent': PrivateTestComponent(
                autoConvert: autoConvert, useSuperCompare: useSuperCompare,usePrivateAction: usePrivateAction),
          },
          connector: PrivateListConnector(userClone:userClone),
        );
}

class PrivateListConnector
    extends ConnOp<ListPrivateTestState, List<ItemBean>> {
  ValueGetter<bool> userClone ;

  PrivateListConnector({this.userClone=_falseValueGetter});

  @override
  List<ItemBean> get(ListPrivateTestState state) {
    return state.data.map((subState) {
      if (userClone()) {
        subState = subState.clone();
      }
      return ItemBean('PrivateComponent', subState);
    }).toList();
  }

  @override
  void set(ListPrivateTestState state, List<ItemBean> subState) {
    state.data = subState.map((itemBean) => itemBean.data).cast<PrivateTestState>().toList();
  }
}

void main() {
  group('Private_reducer_mixin_test', () {
    testWidgets('reducer wantAutoConvert=true', (WidgetTester tester) async {
      await tester.pumpWidget(TestStub(TestPage<ListPrivateTestState, Map>(
          initState: initState,
          view: buildView,
          dependencies: Dependencies(
            adapter:
                NoneConn<ListPrivateTestState>() + PrivateDynamicFlowAdapter(autoConvert: ()=>true),
          )).buildPage(null)));

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

    testWidgets('reducer wantAutoConvert=false', (WidgetTester tester) async {
      bool usePrivateAction=false;
      await tester.pumpWidget(TestStub(TestPage<ListPrivateTestState, Map>(
          initState: initState,
          view: buildView,
          dependencies: Dependencies(
            adapter:
            NoneConn<ListPrivateTestState>() + PrivateDynamicFlowAdapter(autoConvert: ()=>false,usePrivateAction: ()=>usePrivateAction),
          )).buildPage(null)));

      expect(find.text('desc-0'), findsNWidgets(3));

      await tester.tap(find.byKey(const ValueKey<String>('add-1')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(0));
      expect(find.text('desc-1'), findsNWidgets(3));

      usePrivateAction=true;

      await tester.tap(find.byKey(const ValueKey<String>('add-2')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(0));
      expect(find.text('desc-1'), findsNWidgets(2));
      expect(find.text('desc-2'), findsNWidgets(1));

    });

    testWidgets('reducer customCompare', (WidgetTester tester) async {
      await tester.pumpWidget(TestStub(TestPage<ListPrivateTestState, Map>(
          initState: initState,
          view: buildView,
          dependencies: Dependencies(
            adapter:
            NoneConn<ListPrivateTestState>() + PrivateDynamicFlowAdapter(useSuperCompare: ()=>true),
          )).buildPage(null)));

      expect(find.text('desc-0'), findsNWidgets(3));

      await tester.tap(find.byKey(const ValueKey<String>('add-1')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(2));
      expect(find.text('desc-1'), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('add-2')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(1));
      expect(find.text('desc-1'), findsNWidgets(2));

    });

    testWidgets('reducer adapter use userClone', (WidgetTester tester) async {
      bool useSuperCompare=true;

      await tester.pumpWidget(TestStub(TestPage<ListPrivateTestState, Map>(
          initState: initState,
          view: buildView,
          dependencies: Dependencies(
            adapter:
            NoneConn<ListPrivateTestState>() + PrivateDynamicFlowAdapter(useSuperCompare: ()=>useSuperCompare,userClone: ()=>true),
          )).buildPage(null)));

      expect(find.text('desc-0'), findsNWidgets(3));

      await tester.tap(find.byKey(const ValueKey<String>('add-1')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(3));
      expect(find.text('desc-1'), findsNWidgets(0));

      useSuperCompare=false;

      await tester.tap(find.byKey(const ValueKey<String>('add-1')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(2));
      expect(find.text('desc-1'), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey<String>('add-2')));
      await tester.pump();

      expect(find.text('desc-0'), findsNWidgets(1));
      expect(find.text('desc-1'), findsNWidgets(2));

    });
  });

}
