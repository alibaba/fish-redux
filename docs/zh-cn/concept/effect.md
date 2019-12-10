# Effect

Effect顾名思义，用于处理Action的副作用。

我估摸着有人就要问我了，副作用是啥玩意？

打个比方吧，假如我拥有一个函数 `f()`

```text
fn f(x):
  return x * 1
```

此时此刻，另一个函数 `g()`

```text
fn g(x):
  changeSystemEntropy()
  return ax ^ 2 + bx + c
```

我们可以发现，`g()`里边有个改变系统熵的行为。这在函数式编程思想中，就叫做副作用，因为它可能影响到除了这个函数内部自身状态以外的其他状态。

在Fish-Redux中同样，我们通过 `dispatch()` 一些action实现状态修改，但是相对于状态来说，对外部的操作，类似于 `SystemChrome.setSystemUIOverlayStyle()`这样的操作，都是副作用。

现在介绍完了副作用，也没啥可介绍的了。

Effect用法跟Reducer差不太多，但是作用完全不同。

除了上面介绍的场景之外，异步请求也是一个经常会有的情况，这时候Effect可以帮你方便的解决这些问题。

你可以通过控制effect的返回值来达到某些目的，默认情况下，effect会在reducer之前被执行。

当前effect返回 `true` 的时候，就会停止后续的effect和reducer的操作

当前effect返回 `false` 的时候，后续effect和reducer继续执行

-   Effect 是一个处理所有副作用的函数。它接收下面的参数
    -   Action action
    -   Context context
        -   BuildContext context
        -   T state
        -   dispatch
        -   isDisposed
        
Effect会接收来自 View 的“意图”，包括对应的生命周期的回调，然后做出具体的执行。
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
