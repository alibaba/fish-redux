# StaticFlowAdapter

-   The template is an Array that accepts map like data driven.
-   The template receives an array of Dependents.
-   It's very much like a flatMap + compact operation abstractly.
-   Sample Code

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
