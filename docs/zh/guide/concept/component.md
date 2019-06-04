---
title: 组件（Component）
---

组件是对视图展现和逻辑功能的封装。
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

## Reducer

## Effect

## State

## 视图(View)
-   View 是一个输出 Widget 的上下文无关的函数。它接收下面的参数
    -   T state
    -   Dispatch
    -   ViewService
-   它主要包含三方面的信息
    -   视图完全由数据驱动。
    -   视图产生的事件／回调，通过 Dispatch 发出“意图”，但绝不做具体的实现。
    -   使用依赖的组件／适配器，通过在组件上显示配置，再通过 ViewService 标准化调用。
        -   其中 ViewService 提供了三个能力
            -   BuildContext context，获取 flutter Build-Context 的能力
            -   Widget buildView(String name), 直接创建子组件的能力
                -   这里传入的 name 即在 Dependencies 上配置的名称。
                -   创建子组件不需要传入任何其他的参数，因为自组件需要的参数，已经通过 Dependencies 配置中，将它们的数据关系，通过 connector 确立。
            -   ListAdapter buildAdapter()， 直接创建适配器的能力
-   示例代码

```dart
Widget buildMessageView(String message, Dispatch dispatch, ViewService viewService) {
  return Column(children: [
    viewService.buildComponent('profile'),
    InkWell(
      child: Text('$message'),
      onTap: () => dispatch(const Action('onShare')),
    ),
  ]);
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
        );
}
```

## OnError

-   集中处理由 Effect 产生的业务异常，无论是同步函数还是异步函数。有了统一的异常处理机制，我们就能站在一个更高的抽象角度，对业务代码做出合理的简化。
-   示例代码

```dart
bool onMessageError(Exception e, Context<String> ctx) {
    if(e is BizException) {
        ///do some toast
        return true;
    }
    return false;
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
            effect: buildEffect(),
            reducer: buildMessageReducer(),
            onError: onMessageError,
        );
}
```

## ShouldUpdate

-   当数据发生变更，Store 扁平化地通知所有组件
-   框架默认使用 identical 比较新旧两份数据来决定是否需要刷新。
-   如果我们对组件的刷新会有非常精确化的诉求， 那么我们可以自己定义一个 ShouldUpdate。
-   示例代码

```dart
bool shouldUpdate(DetailState old, DetailState now) {
    return old.message != now.message;
}
```
