class _Fields {
  bool isDisposed = false;
  Set<AutoDispose> chilren;
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

  void visit(void Function(AutoDispose) visiter) =>
      _fields.chilren?.forEach(visiter);

  bool get isDisposed => _fields.isDisposed;

  void dispose() {
    /// dispose all children
    if (_fields.chilren != null) {
      final List<AutoDispose> copy = _fields.chilren.toList(growable: false);
      for (AutoDispose child in copy) {
        child.dispose();
      }
      _fields.chilren = null;
    }

    /// Cut off the connection with parent.
    _fields.parent?._fields?.chilren?.remove(this);
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
      newParent._fields.chilren ??= Set<AutoDispose>();
      newParent._fields.chilren.add(this);
    }
    if (oldParent != null) {
      oldParent._fields.chilren.remove(this);
    }
    _fields.parent = newParent;
  }

  AutoDispose regiestOnDisposed(void Function() onDisposed) {
    return AutoDispose()
      ..setParent(this)
      ..onDisposed(onDisposed);
  }

  @deprecated
  void follow(AutoDispose newParent) {
    return setParent(newParent);
  }

  @deprecated
  AutoDispose follower([void Function() onDisposed]) {
    return regiestOnDisposed(onDisposed);
  }
}
