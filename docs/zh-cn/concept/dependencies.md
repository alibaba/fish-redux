# Dependencies

-   Dependencies 是一个表达组件之间依赖关系的结构。它接收两个字段
    -   slots
        -   <String, [Dependent](dependent-cn.md)>{}
    -   [adapter](adapter-cn.md)
-   它主要包含三方面的信息
    -   slots，组件依赖的插槽。
    -   adapter，组件依赖的具体适配器（用来构建高性能的 ListView）。
    -   [Dependent](dependent-cn.md) 是 subComponent | subAdapter + [connector](connector-cn.md) 的组合。
    -   一个 组件的 [Reducer](reducer-cn.md) 由 Component 自身配置的 Reducer 和它的 Dependencies 下的所有子 Reducers 自动复合而成。
-   示例代码

```dart
///register in component
class ItemComponent extends ItemComponent<ItemState> {
  ItemComponent()
      : super(
          view: buildItemView,
          reducer: buildItemReducer(),
          dependencies: Dependencies<ItemState>(
            slots: <String, Dependent<ItemState>>{
              'appBar': AppBarComponent().asDependent(AppBarConnector()),
              'body': ItemBodyComponent().asDependent(ItemBodyConnector()),
              'ad_ball': ADBallComponent().asDependent(ADBallConnector()),
              'bottomBar': BottomBarComponent().asDependent(BottomBarConnector()),
            },
          ),
        );
}

///call in view
Widget buildItemView(ItemState state, Dispatch dispatch, ViewService service) {
  return Scaffold(
      body: Stack(
        children: <Widget>[
          service.buildComponent('body'),
          service.buildComponent('ad_ball'),
          Positioned(
            child: service.buildComponent('bottomBar'),
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
            height: 100.0,
          ),
        ],
      ),
      appBar: AppbarPreferSize(child: service.buildComponent('appBar')));
}
```
