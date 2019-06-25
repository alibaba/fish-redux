import '../redux/redux.dart';
import 'basic.dart';
import 'dependent.dart';

class Dependencies<T> {
  final Map<String, Dependent<T>> slots;
  final Dependent<T> list;

  /// Use [list: NoneConn<T>() + Adapter<T>()] instead of [adapter: Adapter<T>()],
  /// Which is better reusability and consistency.
  Dependencies({
    this.slots,
    @deprecated AbstractAdapter<T> adapter,
    Dependent<T> list,
  })  : assert(list == null || list.isAdapter(),
            'The dependent must contains adapter.'),
        assert(list == null || adapter == null,
            'Only one style of adapter could be applied.'),
        list = list ?? (_NoneConn<T>() + adapter);

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

class _NoneConn<T> extends ImmutableConn<T, T> {
  @override
  T get(T state) => state;

  @override
  T set(T state, T subState) => subState;

  Dependent<T> operator +(AbstractLogic<T> logic) =>
      createDependent<T, T>(this, logic);
}
