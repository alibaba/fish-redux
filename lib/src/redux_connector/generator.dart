String Function() generator() {
  int nextId = 0;
  String prefix = '';
  return () {
    if (++nextId >= 0x3FFFFFFFFFFFFFFF) {
      nextId = 0;
      prefix = '\$' + prefix;
    }
    return prefix + nextId.toString();
  };
}
