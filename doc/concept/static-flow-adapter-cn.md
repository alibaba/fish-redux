# StaticFlowAdapter

-   模版是一个 Array，接受 Object|Map 的数据驱动。
-   模版接收一个 Dependent 的数组，每一个 Dependent 可以是 Component 或者 Adapter + Connector<T,P> 的组合。
-   抽象地看，它非常的像是一个 flatMap + compact 的操作。
-   示例代码

```dart
class ItemBodyComponent extends Component<ItemBodyState> {
    ItemBodyComponent()
        : super(
            view: buildItemBody,
            dependencies: Dependencies<ItemBodyState>(
            adapter: StaticFlowAdapter<ItemBodyState>(
                slots: <Dependent<ItemBodyState>>[
                    VideoAdapter().asDependent(videoConnector()),
                    UserInfoComponent().asDependent(userInfoConnector()),
                    DescComponent().asDependent(descConnector()),
                    ItemImageComponent().asDependent(itemImageConnector()),
                    OriginDescComponent().asDependent(originDescConnector()),
                    VisitComponent().asDependent(visitConnector()),
                    SameMoreComponent().asDependent(sameMoreConnector()),
                    PondComponent().asDependent(pondConnector()),
                    CommentAdapter().asDependent(commentConnector()),
                    RecommendAdapter().asDependent(recommendConnector()),
                    PaddingComponent().asDependent(paddingConnector()),
                ]),
            ),
        );
}

```

<img src="https://img.alicdn.com/tfs/TB1sXXOLQvoK1RjSZPfXXXPKFXa-1666-1104.png" width="833px" height="552px">
