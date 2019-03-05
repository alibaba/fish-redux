# Filter

-   Filter 是用来优化 Reducer 的性能的。因为 Reducer 是层层组装的，所以处理每一个 Action，理论上会遍历一遍所有的小 Reducer，在一些非常复杂的场景下，这样的一次深度遍历的耗时可能会到毫秒级别（一般情况下都应该小于 1 毫秒）。那么我们需要对 Reducer 做性能优化，提前决定要不要遍历这份 Reducer 子树，减少遍历的深度和次数。
-   示例代码

```dart
bool filter(Action action) {
    return action.type == 'some action';
}
```
