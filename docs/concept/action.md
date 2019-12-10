# Action

-   Action contains two fields
    -   type
    -   payload
-   Recommended way of writing action
    -   Create an action.dart file for a component|adapter that contains two classes
        -   An enumeration class for the type field
        -   An ActionCreator class is created for the creator of the Action, which helps to constrain the type of payload.
    -   Effect Accepted Action which's type is named after `on{verb}`
    -   Reducer Accepted Action which's type is named after `{verb}`
    -   Sample code

```dart
enum MessageAction {
    onShare,
    shared,
}

class MessageActionCreator {
    static Action onShare(Map<String, Object> payload) {
        return Action(MessageAction.onShare, payload: payload);
    }

    static Action shared() {
        return const Action(MessageAction.shared);
    }
}
```
