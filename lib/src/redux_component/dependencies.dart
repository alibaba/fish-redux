import '../redux/redux.dart';
import 'basic.dart';

class Dependencies<T> {
  /// 可空
  final Map<String, Dependent<T>>? slots;
  /// 可空
  final Dependent<T>? adapter;

  /// Use [adapter: NoneConn<T>() + Adapter<T>()] instead of [adapter: Adapter<T>()],
  /// Which is better reusability and consistency.
  Dependencies({
    this.slots,
    this.adapter,
  }) : assert(adapter == null || adapter.isAdapter(),
            'The dependent must contains adapter.');

  /// 可空 combine_reducers.dart#32
  Reducer<T>? createReducer() {
    final List<SubReducer<T>?> subs = <SubReducer<T>?>[];
    if (slots != null && slots?.isNotEmpty == true) {
      subs.addAll(slots!.entries.map<SubReducer<T>?>(
        (MapEntry<String, Dependent<T>> entry) =>
            entry.value.createSubReducer(),
      ));
    }

    if (adapter != null) {
      subs.add(adapter?.createSubReducer());
    }

    return combineReducers(<Reducer<T>?>[combineSubReducers(subs)]);
  }

  /// 可空
  Dependent<T>? slot(String type) {
    if(slots != null && slots?.isNotEmpty == true){
      return slots![type];
    }
    return null;
  }

  /// 可空
  Dependencies<T>? trim() =>
      adapter != null || slots?.isNotEmpty == true ? this : null;
}
