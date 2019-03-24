bool _debugFlag = false;

bool isDebug() {
  assert(() {
    _debugFlag = true;
    return _debugFlag;
  }());
  return _debugFlag;
}

bool println(Object object) {
  print(object);
  return true;
}
