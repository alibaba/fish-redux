---
title: ConnOp 类
---

```dart
class ConnOp<T, P> extends MutableConn<T, P>
```

```dart
class PageConnector extends ConnOp<AppState, PageState> {

  @override
  PageState get(AppState state) {
    // TODO: implement get
    return super.get(state);
  }

  @override
  void set(AppState state, PageState subState) {
    // TODO: implement set
    super.set(state, subState);
  }
}
```