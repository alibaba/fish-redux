import '../aop.dart';

bool _listEquals<E>(List<E> list1, List<E> list2) {
  if (identical(list1, list2)) {
    return true;
  }
  if (list1 == null || list2 == null) {
    return false;
  }
  final int length = list1.length;
  if (length != list2.length) {
    return false;
  }
  for (int i = 0; i < length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }
  return true;
}

/// memoize returns cached result of function call when inputs were not changed from previous invocation.
ApplyLikeEnhancer memoize() {
  return (dynamic Function(List<dynamic>) functor) {
    List<dynamic> memoizeArguments;
    dynamic memoizeResult;
    bool hasBeenCalled = false;

    return (List<dynamic> positionalArguments,
        [Map<Symbol, dynamic> namedArguments]) {
      if (!hasBeenCalled ||
          !_listEquals<dynamic>(positionalArguments, memoizeArguments)) {
        memoizeResult = functor(positionalArguments);
        memoizeArguments = positionalArguments;
        hasBeenCalled = true;
      }

      return memoizeResult;
    };
  };
}
