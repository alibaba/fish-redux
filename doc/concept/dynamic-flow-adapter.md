# DynamicFlowAdapter

-   The template is a Map that accepts an array-like data driven
-   Sample Code

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
