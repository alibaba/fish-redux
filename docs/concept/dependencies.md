# Dependencies

-   Dependencies is a structure that expresses dependencies between components. It accepts two fields
    -   slots
        -   <String, [Dependent](dependent.md)>{}
    -   [adapter](adapter.md)
-   It mainly contains three aspects of information
    -   The slots that the component depends on.
    -   The adapter that the component depends on (used to build a high-performance ListView).
    -   [Dependent](dependent.md) Is a combination of subComponent | subAdapter + [connector](connector.md)。
    -   A component's [Reducer](reducer.md) is automatically compounded by the Reducer configured by the Component itself and all of the Reducers under its Dependencies.
-   Sample Code

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
