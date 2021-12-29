import 'package:fish_redux/fish_redux.dart';
import 'state.dart';
import '../page/state.dart';

class ReportConnector extends ConnOp<PageState, ReportState> {
  @override
  ReportState get(PageState state) {
    int done = 0;
    // for (var item in (state?.toDos ?? [])) {
    //   done = done + (item.isDone ? 1 : 0);
    // }
    return ReportState()..total = state?.toDos?.length ?? 0..done = done;
  }

  @override
  void set(PageState state, ReportState subState) {}
}
