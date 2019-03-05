bool _debugFlag = false;

bool isDebug() {
  assert(() {
    _debugFlag = true;
    return true;
  }());
  return _debugFlag;
}

bool println(Object object) {
  print(object);
  return true;
}
