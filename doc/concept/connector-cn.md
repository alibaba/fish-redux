# Connector<T, P>

-   它表达了如何从一个大数据中读取小数据，同时对小数据的修改如何同步给大数据，这样的数据连接关系。
-   它是将一个集中式的 Reducer，可以由多层次多模块的小 Reducer 自动拼装的关键。
    -   它大大降低了我们使用 Redux 的复杂度。我们不再关心组装过程，我们关心的核心是什么动作促使数据怎么变化。
-   它使用在配置 Dependencies 中，在配置中我们就固化了大组件和小组件之间的连接关系(数据管道)，所以在我们使用小组件的时候是不需要传入任何动态参数的。
-   ![image.png | left | 719x375](https://cdn.nlark.com/lark/0/2018/png/82574/1545365202743-01074be7-f067-45c7-aae0-91b12cd50ae6.png)

-   Sample Code

```dart
class DetialState {
    Profile profile;
    String message;
}

ConnOp<DetialState, String> messageConnector() {
    return ConnOp<DetialState, String>(
        get: (DetialState state) => state.message,
        set: (DetialState state, String message) => state.message = message,
    );
}
```
