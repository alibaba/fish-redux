---
title: 适配器（Adapter）
---

通常，我们对 ListView 的分治更多的局限于它展现部分，而它的逻辑部分往往是集中的。当我们试图将 ListView 内的某一局部的展现和逻辑封装在一起，我们就会遇到`Big-Cell`问题，面临性能的显著降低。这里面存在一个分治和性能上的矛盾。这个矛盾带来了复用难，可维护差，难以协作等中大型场景下的问题。

解决这个问题，有两种思路：
1. 下沉到 UI 表达层（Widgets），去实现一个高性能的 ScrollView。
2. 向上做模型抽象，得到一个逻辑上的 ScrollView，性能上的 ListView。

Fish Redux 选择了第二条更加通用的路径来解决 ListView 下的分治问题。
一个 ListView 对应了一个 Adapter，这看上去非常的像 Android 里的设计，但事实上 Fish Redux 里的 Adapter 概念走的更远。
1. 一个 Adapter 是可以由多个 Component 和 Adapter 组合而成，它有点像 flatmap & compact 的 api 的叠加。
2. Adapter 以及它的子 Adapter 的生命周期是和 ListView 是一致的。它像跨斗一般附着于 ListView 的生命周期之上。同时由于 Adapter 生命周期的提升，我们额外收获了两个非常有用的事件消息，appear 和 disappear。

注意 ⚠️ 在 Adapter 里配置的子 Component，它的生命周期和它所对应的 WidgetState 是一致的，所以它是短暂的。

我们在基础 Component 的概念外，额外增加了一种组件化的抽象 Adapter。它的目标是解决 Component 模型在 ListView 的场景下的 3 个问题：
  1. 将一个"Big-Cell"放在 ListView 里，无法享受 ListView 代码的性能优化。
  2. Component 无法区分 appear|disappear 和 init|dispose 事件。
  3. Effect 的生命周期和 View 的耦合，在 ListView 的有些场景下不符合直观的预期。

Adapter 和 Component 的行为几乎都是一致的，除了以下几点：
  - Component 生成一个 Widget，而 Adapter 生成一个 ListAdapter，ListAdapter 可以生成一组 Widget 。
  - 不具体生成 Widget，而是一个 ListAdapter，能非常大的提升页面帧率和流畅度。
  - 生命周期
    - Component 的 Effect 是跟着 Widget 的生命周期走的，Adapter 的 Effect 是跟着上一级的 Widget 的生命周期走。
    - Effect​ 提升，极大的解除了业务逻辑和视图生命的耦合，即使它的展示还未出现，的其他模块依然能通过 dispatch-api，调用它的能力。
  - appear|disappear 的通知
  - 由于 Effect 生命周期的提升，我们就能更加精细的区分 init|dispose 和 appear|disappear。而这在 Component 的模型中是无法区分的。
  - Reducer is long-lived, Effect is medium-lived, View is short-lived.

## Adapter 的三种实现

### DynamicFlowAdapter

模版是一个 Map，接受一个数组类型的数据驱动

示例代码

```dart
class RecommendAdapter extends DynamicFlowAdapter<RecommendState> {
  RecommendAdapter() : super(
    pool: <String, Component<Object>>{
      'card_0': RecommendTitleComponent(),
      'card_1': RecommendRowComponent(),
    },
    connector: RecommendCardListConnector(),
  );
}
```
<img src="https://img.alicdn.com/tfs/TB10lxHLMDqK1RjSZSyXXaxEVXa-1838-1024.png" width="919px" height="512px">

### StaticFlowAdapter

模版是一个 Array，接受 Object|Map 的数据驱动。
模版接收一个 Dependent 的数组，每一个 Dependent 可以是 Component 或者 Adapter + Connector<T,P> 的组合。
抽象地看，它非常的像是一个 flatMap + compact 的操作。

示例代码

```dart
class ItemBodyComponent extends Component<ItemBodyState> {
  ItemBodyComponent() : super(
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

### CustomAdapter

对大 Cell 的自定义实现。要素和 Component 类似，不一样的地方是 Adapter 的视图部分返回的是一个 ListAdapter。

示例代码

```dart
class CommentAdapter extends Adapter<CommentState> {
  CommentAdapter() : super(
    adapter: buildCommentAdapter,
    effect: buildCommentEffect(),
    reducer: buildCommentReducer(),
  );
}

ListAdapter buildCommentAdapter(CommentState state, Dispatch dispatch, ViewService service) {
  final List<IndexedWidgetBuilder> builders = Collections.compact(<IndexedWidgetBuilder>[]
  ..add((BuildContext buildContext, int index) =>
    _buildDetailCommentHeader(state, dispatch, service))
  ..addAll(_buildCommentViewList(state, dispatch, service))
  ..add(isEmpty(state.commentListRes?.items)
    ? (BuildContext buildContext, int index) =>
        _buildDetailCommentEmpty(state.itemInfo, dispatch)
    : null)
  ..add(state.commentListRes?.getHasMore() == true
    ? (BuildContext buildContext, int index) => _buildLoadMore(dispatch)
    : null));
  return ListAdapter(
  (BuildContext buildContext, int index) =>
      builders[index](buildContext, index),
  builders.length,
  );
}

///builds
```