# DynamicFlowAdapter

-   模版是一个 Map，接受一个数组类型的数据驱动
-   示例代码

```dart
class RecommendAdapter extends DynamicFlowAdapter<RecommendState> {
    RecommendAdapter()
        : super(
            pool: <String, Component<Object>>{
                'card_0': RecommendTitleComponent(),
                'card_1': RecommendRowComponent(),
            },
            connector: RecommendCardListConnector(),
        );
}
```
<img src="https://img.alicdn.com/tfs/TB10lxHLMDqK1RjSZSyXXaxEVXa-1838-1024.png" width="919px" height="512px">
