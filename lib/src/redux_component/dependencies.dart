import '../redux/redux.dart';
import 'basic.dart';

class Dependencies<T> {
  final Map<String, Dependent<T>> slots;
  final AbstractAdapter<T> adapter;

  Dependencies({this.slots, this.adapter});

  Reducer<T> get reducer {
    Reducer<T> slotsReducer;
    if (slots != null && slots.isNotEmpty) {
      slotsReducer = combineSubReducers(slots.entries.map<SubReducer<T>>(
        (MapEntry<String, Dependent<T>> entry) =>
            entry.value.createSubReducer(),
      ));
    }
    return combineReducers(<Reducer<T>>[slotsReducer, adapter?.reducer]);
  }

  Dependent<T> slot(String type) => slots[type];
}
