---
title: Reselecte 类
---

```dart
abstract class Reselect<T, P> extends _BasicReselect<T, P>
```


```dart
class PageConnector extends Reselect<AppState, PageState> {
  @override
  PageState computed(List list) {
    // TODO: implement computed
    return null;
  }

  @override
  List getSubs(AppState state) {
    // TODO: implement getSubs
    return null;
  }

  @override
  void set(AppState state, PageState subState) {
    // TODO: implement set
  }
}
```