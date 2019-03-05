# CustomAdapter

-   Custom implementation of large Cell in LisView.
-   The Factors of the Adapter are similar to the Component's. The difference is that the view part of the Adapter returns a ListAdapter.
-   Sample Code

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
