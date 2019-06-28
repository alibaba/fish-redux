class _Fields {
  bool isDisposed = false;
  Set<AutoDispose> children;
  AutoDispose parent;
  void Function() onDisposed;
}

/// Ultra-lightweight lifecycle management system
/// When an object's dispose is called
///  1. Dispose all children
///  2. Cut off the connection with parent
///  3. The hook function of onDisposed is triggered
///  4. Status marked as isDisposed = true
class AutoDispose {
  final _Fields _fields = _Fields();

  void visit(void Function(AutoDispose) visitor) =>
      _fields.children?.forEach(visitor);

  bool get isDisposed => _fields.isDisposed;

  void dispose() {
    /// dispose all children
    if (_fields.children != null) {
      final List<AutoDispose> copy = _fields.children.toList(growable: false);
      for (AutoDispose child in copy) {
        child.dispose();
      }
      _fields.children = null;
    }

    /// Cut off the connection with parent.
    _fields.parent?._fields?.children?.remove(this);
    _fields.parent = null;

    /// The hook function of onDisposed is triggered.
    _fields.onDisposed?.call();
    _fields.onDisposed = null;

    /// Status marked as isDisposed = true.
    _fields.isDisposed = true;
  }

  void onDisposed(void Function() onDisposed) {
    assert(_fields.onDisposed == null);
    if (_fields.isDisposed) {
      onDisposed?.call();
    } else {
      _fields.onDisposed = onDisposed;
    }
  }

  void setParent(AutoDispose newParent) {
    assert(newParent != this);

    final AutoDispose oldParent = _fields.parent;
    if (oldParent == newParent || isDisposed) {
      return;
    }

    if (newParent != null && newParent.isDisposed) {
      dispose();
      return;
    }

    if (newParent != null) {
      newParent._fields.children ??= <AutoDispose>{};
      newParent._fields.children.add(this);
    }
    if (oldParent != null) {
      oldParent._fields.children.remove(this);
    }
    _fields.parent = newParent;
  }

  AutoDispose registerOnDisposed(void Function() onDisposed) => AutoDispose()
    ..setParent(this)
    ..onDisposed(onDisposed);
}
