---
title: 组件（Component）
---

视图展现和逻辑功能的封装。

面向当下，从 Redux 的视角看，我们对组件分为状态修改的功能(Reducer)和其他。
面向未来，从 UI-Automation 的视角看，我们对组件分为展现表达和其他。
结合上面两个视角，于是我们得到了，View、 Effect、Reducer 三部分，称之为组件的三要素，分别负责了组件的展示、非修改数据的行为、修改数据的操作。

我们以显式配置的方式来完成大组件所依赖的小组件、适配器的注册，这份依赖配置称之为 Dependencies。

所以有了这个公式
Component = View + Effect(可选) + Reducer(可选) + Dependencies(可选)

分治：从组件的角度
<img src="https://img.alicdn.com/tfs/TB1vqB2J4YaK1RjSZFnXXa80pXa-900-780.png" width="450px" height="390px">

集中：从 Store 的角度
<img src="https://img.alicdn.com/tfs/TB1sThMJYvpK1RjSZFqXXcXUVXa-1426-762.png" width="713px" height="381px">


## View
View 是一个输出 Widget 的上下文无关的函数。它接收下面的参数：
  - state
  - dispatch
  - viewService

它主要包含三方面的信息：视图完全由数据驱动；视图产生的事件／回调，通过 Dispatch 发出“意图”，但绝不做具体的实现；以及使用依赖的组件／适配器，通过在组件上显示配置，再通过 ViewService 标准化调用。其中 ViewService 提供了三个能力：
  - BuildContext context，获取 flutter Build-Context 的能力
  - Widget buildView(String name), 直接创建子组件的能力
    - 这里传入的 name 即在 Dependencies 上配置的名称。
    - 创建子组件不需要传入任何其他的参数，因为自组件需要的参数，已经通过 Dependencies 配置中，将它们的数据关系，通过 connector 确立。
  - ListAdapter buildAdapter()， 直接创建适配器的能力

示例代码

```dart
Widget buildMessageView(String message, Dispatch dispatch, ViewService viewService) {
  return Column(children: [
    viewService.buildComponent('profile'),
    InkWell(
      child: Text(message),
      onTap: () => dispatch(const Action('onShare')),
    ),
  ]);
}

class MessageComponent extends Component<String> {
  MessageComponent(): super(view: buildMessageView);
}
```


## State

...


## Action

...

## Reducer

Reducer 是一个上下文无关的纯函数。它接收下面的参数：
  - T state
  - Action action

它主要包含三方面的信息：
  - 接收一个“意图”， 做出数据修改。
  - 如果要修改数据，需要创建一份新的拷贝，修改在拷贝上。
  - 如果数据修改了，它会自动触发 State 的层层数据的拷贝，再以扁平化方式通知组件刷新。

示例代码

第一种写法
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

第二种写法（推荐）
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


## Effect

Effect 是一个处理所有副作用的函数。它接收下面的参数：
  - Action action
  - Context context
    - BuildContext context
    - T state
    - dispatch
    - isDisposed

它主要包含四方面的信息：
  - 接收来自 View 的“意图”，包括对应的生命周期的回调，然后做出具体的执行。
  - 它的处理可能是一个异步函数，数据可能在过程中被修改，所以我们应该通过 context.state 获取最新数据。
  - 如果它要修改数据，应该发一个 Action 到 Reducer 里去处理。它对数据是只读的，不能直接去修改数据。
  - 如果它的返回值是一个非空值，则代表自己优先处理，不再做下一步的动作；否则广播给其他组件的 Effect 部分，同时发送给 Reducer。

Self-First-Broadcast。
![image.png | left | 747x399](https://cdn.nlark.com/lark/0/2018/png/82574/1545365233153-4c8105b4-050c-49e6-be02-dbf28a861caa.png)


示例代码

第一种写法
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

第二种写法
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