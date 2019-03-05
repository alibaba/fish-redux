class Track {
  final List<Pin> _pins = <Pin>[];

  Track();

  factory Track.tags(List<String> tags) {
    tags ??= <String>[];

    final Track tracer = Track();
    tags.forEach((String tag) => tracer.append(tag));

    return tracer;
  }

  factory Track.pins(List<Pin> tags) {
    tags ??= <Pin>[];

    final Track tracer = Track();
    tags.forEach((Pin pin) => tracer.append(pin.tag, pin.value));

    return tracer;
  }

  void append(String tag, [Object value]) {
    _pins.add(Pin(tag, value));
  }

  int countOfTag(String tag) =>
      _pins.fold<int>(0, (count, pin) => pin.tag == tag ? count + 1 : count);

  void remove(String tag) => _pins.retainWhere((pin)=>pin.tag == tag);

  String toString() => _pins
      .map<String>((node) => node.toString())
      .fold<String>('', (prev, now) => '$prev\n=>$now');

  @override
  bool operator ==(dynamic other) {
    if (!(other is Track)) return false;

    if (_pins.length != other._pins.length) return false;

    for (int index = 0; index < _pins.length; index++) {
      if (_pins[index] != other._pins[index]) return false;
    }

    return true;
  }

  void reset() {
    _pins.clear();
  }
}

class Pin {
  String tag;
  Object value;
  DateTime timeStamp;

  Pin(this.tag, [Object value])
      : timeStamp = DateTime.now(),
        value = value is Function ? value() : value;

  @override
  String toString() => '$tag<${value?.toString()}>';

  @override
  bool operator ==(dynamic other) {
    if (!(other is Pin)) return false;

    return other.tag == tag && other.value == value;
  }
}
