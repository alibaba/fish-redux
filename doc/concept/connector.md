# Connector<T, P>

-   It expresses a data connection relationship of how to read small data from a big data, and how to synchronize to big data when the small data is modified。
-   It is the key to a centralized Reducer that can be assembled automatically by a multi-level, multi-module, small Reducer
    -   It greatly reduces the difficulty of using Redux. We no longer care about the assembly process, we care about what specific actions cause the state to change.
-   It is used in the configuration Dependencies, in the configuration we have solidified the connection between the large component and the small component, so we do not need to pass in any dynamic parameters when we use the small component.
-   ![image.png | left | 719x375](https://cdn.nlark.com/lark/0/2018/png/82574/1545365202743-01074be7-f067-45c7-aae0-91b12cd50ae6.png)

-   Sample Code

```dart
class DetialState {
    Profile profile;
    String message;
}

ConnOp<DetialState, String> messageConnector() {
    return ConnOp<DetialState, String>(
        get: (DetialState state) => state.message,
        set: (DetialState state, String message) => state.message = message,
    );
}
```
