# Reducer

-   The Reducer is a context-independent pure function. It receives the following parameters
    -   T state
    -   Action action
-   It mainly contains three aspects of information
    -   Receive an "intent" and make a state modification.
    -   If you want to modify the state, you need to create a new copy and modify it on the copy.
    -   If the small state is modified, it will automatically trigger the copy of the main state's layers data, and then notify the components to refresh in a flattened manner.
-   Sample Code

```dart
/// one style of writing
String messageReducer(String msg, Action action) {
  if (action.type == 'shared') {
    return '$msg [shared]';
  }
  return msg;
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
            effect: buildEffect(),
            reducer: messageReducer,
        );
}
```

```dart
/// another style of writing
Reducer<String> buildMessageReducer() {
  return asReducer(<Object, Reducer<String>>{
    'shared': _shared,
  });
}

String _shared(String msg, Action action) {
  return '$msg [shared]';
}

class MessageComponent extends Component<String> {
    MessageComponent(): super(
            view: buildMessageView,
            effect: buildEffect(),
            reducer: buildMessageReducer(),
        );
}
```

> 推荐的是第二种写法
