# Filter

-   Filter is used to optimize the performance of the Reducer. Because the Reducer is layer-assembled, each Action is processed, and in theory, all the small Reducers are traversed. In some very complicated scenarios, such a deep traversal may take up to the millisecond level (generally Should be less than 1 millisecond). Then we need to optimize the performance of the Reducer, decide in advance whether to traverse this Reducer subtree, reduce the depth and number of traversal.
-   Sample Code

```dart
bool filter(Action action) {
    return action.type == 'some action';
}
```
