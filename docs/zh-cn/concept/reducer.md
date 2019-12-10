# Reducer

-   Reducer 是一个上下文无关的 pure function。它接收下面的参数
    -   T state
    -   Action action
-   它主要包含三方面的信息
    -   接收一个“意图”， 做出数据修改。
    -   如果要修改数据，需要创建一份新的拷贝，修改在拷贝上。
    -   如果数据修改了，它会自动触发 State 的层层数据的拷贝，再以扁平化方式通知组件刷新。
-   示例代码

```dart
/// one style of writing
String messageReducer(String msg, Action action) {
  if (action.type == 'shared') {
    return '$msg [shared]';
  }
  return msg;
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
            effect: buildEffect(),
            reducer: messageReducer,
        );
}
```

```dart
/// another style of writing
Reducer<String> buildMessageReducer() {
  return asReducer(<Object, Reducer<String>>{
    'shared': _shared,
  });
}

String _shared(String msg, Action action) {
  return '$msg [shared]';
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
            effect: buildEffect(),
            reducer: buildMessageReducer(),
        );
}
```

> 推荐的是第二种写法
