# CustomAdapter

-   对大 Cell 的自定义实现
-   要素和 Component 类似，不一样的地方是 Adapter 的视图部分返回的是一个 ListAdapter
-   示例代码

```dart
class CommentAdapter extends Adapter<CommentState> {
    CommentAdapter()
        : super(
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
