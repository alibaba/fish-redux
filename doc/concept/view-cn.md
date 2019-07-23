# View

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
                -   创建子组件不需要传入任何其他的参数，因为子组件需要的参数，已经通过 Dependencies 配置中，将它们的数据关系，通过 connector 确立。
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
