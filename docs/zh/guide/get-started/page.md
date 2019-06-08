---
title: 写一个页面
---

## View

## State

## Action

构造一个`Action`类，需要两个参数：
1. type
2. payload - 可选


推荐的写法
1. 创建一个`action.dart`文件，包含两个类
    - 为 type 字段起一个枚举类
    - 为 Action 的创建起一个 ActionCreator 类，这样利于约束 payload 的类型。
```dart
enum MessageAction {
    onShare,
    shared,
}

class MessageActionCreator {
  static Action onShare(Map<String, Object> payload) {
    return Action(MessageAction.onShare, payload: payload);
  }

  static Action shared() {
    return const Action(MessageAction.shared);
  }
}
```

## Reducer

Reducer 接受处理的 Action，以{verb} 命名
```dart
```

## Effect

Effect 接受处理的 Action，以 on{Verb} 命名
```dart
```