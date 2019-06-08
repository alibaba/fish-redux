---
title: ShouldUpdate
---

# ShouldUpdate

当数据发生变更，Store 会扁平化地通知所有组件，并且使用 Identical （默认）比较新旧两份数据来决定是否需要刷新。如果对组件的刷新会有非常精确化的诉求，那么我们可以自己定义一个 ShouldUpdate。

示例代码
```dart
bool shouldUpdate(DetailState old, DetailState now) {
  return old.message != now.message;
}
```
