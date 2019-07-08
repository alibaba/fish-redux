String Function() generator() {
  int nextId = 0;
  String prefix = '';
  return () {
    /// fix '0x3FFFFFFFFFFFFFFF' can't be represented exactly in JavaScript.
    if (++nextId >= 0x3FFFFFFF) {
      nextId = 0;
      prefix = '\$' + prefix;
    }
    return prefix + nextId.toString();
  };
}
