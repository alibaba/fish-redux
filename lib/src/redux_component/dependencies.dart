import '../redux/redux.dart';
import '../redux_connector/redux_connector.dart';
import 'basic.dart';

class Dependencies<T> {
  final Map<String, Dependent<T>> slots;
  final Dependent<T> list;

  /// Use [list: NoneConn<T>() + Adapter<T>()] instead of [adapter: Adapter<T>()],
  /// Which is better reusability and consistency.
  Dependencies({
    this.slots,
    @deprecated AbstractAdapter<T> adapter,
    Dependent<T> list,
  })  : assert(list == null || list.isAdapter(), ''),
        assert(list == null || adapter == null, ''),
        list = list ?? (NoneConn<T>() + adapter);

  Reducer<T> get reducer {
    final List<SubReducer<T>> subs = <SubReducer<T>>[];
    if (slots != null && slots.isNotEmpty) {
      subs.addAll(slots.entries.map<SubReducer<T>>(
        (MapEntry<String, Dependent<T>> entry) =>
            entry.value.createSubReducer(),
      ));
    }

    if (list != null) {
      subs.add(list.createSubReducer());
    }

    return combineReducers(<Reducer<T>>[combineSubReducers(subs)]);
  }

  Dependent<T> slot(String type) => slots[type];
}
