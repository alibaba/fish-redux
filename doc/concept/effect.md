# Effect

-   Effect is a function that handles all side effects. It receives the following parameters
    -   Action action
    -   Context context
        -   BuildContext context
        -   T state
        -   dispatch
        -   isDisposed
-   It mainly contains four aspects of information
    -   Receive "intent" from the View, including the corresponding lifecycle callback, and then make specific execution.
    -   Its processing may be an asynchronous function, the data may be changed in the process, so we should get the latest data through context.state.
    -   If you want to modify the data, you should send an Action to the Reducer to handle. It is read-only for data and cannot be modified directly in a effect function.
    -   If its return value is a non-null value, it will take precedence for itself and will not do the next step; otherwise it will broadcast to the Effect part of other components and sent the action to the Reducer.

> Self-First-Broadcast。
> ![image.png | left | 747x399](https://cdn.nlark.com/lark/0/2018/png/82574/1545365233153-4c8105b4-050c-49e6-be02-dbf28a861caa.png)

-   Sample Code

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
