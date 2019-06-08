---
title: 复合组件
---

# Dependencies

有些时候，一个组件可能是由多个组件组成的，我们称之为复合组件。在 `Fish-Redux` 中，我们使用 `Dependencies` 来表达了复合组件内，组件之间依赖关系的结构。它接收两个具名参数：
  - slots
  - [adapter](../concept/adapter.html)

**复合组件也是一个组件，和普通组件不同的是， `Reducer` 是复合组件自身所定义的和内部其他组件所定义的复合而成。**

## Dependent

在介绍 `Dependencies` 的参数之前，我们先了解一些什么是 `Dependent` 。

`Dependent` 由组件(Component)或者适配器(Adapter)，再附加上组件的 `Connector` 而组成的，它定义了组件如何与复合组件连接的。

## slots

用于表达复合组件内有哪些组件，是一个以 `String` 为键，`Dependent` 为值的 `Map` 结构。

## adapter

适配器

## 示例

```dart
// register in component
class HomePage extends Page<HomeState, Map<String, dynamic>> {
  HomePage() : super(
    view: buildView,
    reducer: buildReducer(),
    dependencies: Dependencies<HomeState>(
      slots: <String, Dependent<HomeState>>{
        'appBar': AppBarComponent().asDependent(AppBarConnector()),
      },
      adapter: ListAdapter(),
    ),
  );
}

// call in view
Widget buildView(HomeState state, Dispatch dispatch, ViewService viewService) {
  final adapter = viewService.buildAdapter();
  return Scaffold(
    body: ListView.builder(
      itemBuilder: adapter.itemBuilder,
      itemCount: adapter.itemCount,
    );
    appBar: service.buildComponent('appBar'),
  );
}
```