# ShouldUpdate

-   When the state changes, the store flatly notifies all the components.
-   By default, the framework uses identical to compare the old and new state to determine if a refresh is needed.
-   If we have a very precise request for component refresh, then we can define a ShouldUpdate ourselves.
-   Sample Code

```dart
bool shouldUpdate(DetailState old, DetailState now) {
    return old.message != now.message;
}
```
