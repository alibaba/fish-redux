import 'package:fish_redux/fish_redux.dart';
import 'package:sample/global_store/reducer.dart';
import 'package:sample/global_store/state.dart';

class GlobalStore{
  static Store<GlobalState> _globalStore;
  static GlobalState get state => store.getState();

  static Store<GlobalState> get store{
    if(null == _globalStore){
      _globalStore = createStore<GlobalState>(initState(null), buildReducer());
    }
    return _globalStore;
  }
  
}