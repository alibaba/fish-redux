# Effect

-   Effect 是一个处理所有副作用的函数。它接收下面的参数
    -   Action action
    -   Context context
        -   BuildContext context
        -   T state
        -   dispatch
        -   isDisposed
-   它主要包含四方面的信息
    -   接收来自 View 的“意图”，包括对应的生命周期的回调，然后做出具体的执行。
    -   它的处理可能是一个异步函数，数据可能在过程中被修改，所以我们应该通过 context.state 获取最新数据。
    -   如果它要修改数据，应该发一个 Action 到 Reducer 里去处理。它对数据是只读的，不能直接去修改数据。
    -   如果它的返回值是一个非空值，则代表自己优先处理，不再做下一步的动作；否则广播给其他组件的 Effect 部分，同时发送给 Reducer。

> Self-First-Broadcast。
> ![image.png | left | 747x399](https://cdn.nlark.com/lark/0/2018/png/82574/1545365233153-4c8105b4-050c-49e6-be02-dbf28a861caa.png)

-   示例代码

```dart
/// one style of writing
FutureOr<Object> sideEffect(Action action, Context<String> ctx) async {
  if (action.type == Lifecycle.initState) {
    //do something on initState
    return true;
  } else if (action.type == 'onShare') {
    //do something on onShare
    await Future<void>.delayed(Duration(milliseconds: 1000));
    ctx.dispatch(const Action('shared'));
    return true;
  }
  return null;
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
            effect: sideEffect,
        );
}
```

```dart
/// another style of writing
Effect<String> buildEffect() {
  return combineEffects(<Object, Effect<String>>{
    Lifecycle.initState: _initState,
    'onShare': _onShare,
  });
}

void _initState(Action action, Context<String> ctx) {
  //do something on initState
}

void _onShare(Action action, Context<String> ctx) async {
  //do something on onShare
  await Future<void>.delayed(Duration(milliseconds: 1000));
  ctx.dispatch(const Action('shared'));
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
            effect: buildEffect(),
        );
}
```
