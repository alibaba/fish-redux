---
title: 连接器（Connector）
---

在解答 connector 是什么之前，我们来先看一个代码片段

```javascript
let hasChanged = false;
const nextState = {};
for (let i = 0; i < finalReducerKeys.length; i++) {
	const key = finalReducerKeys[i];
	const reducer = finalReducers[key];
	const previousStateForKey = state[key];
	const nextStateForKey = reducer(previousStateForKey, action);
	if (typeof nextStateForKey === 'undefined') {
		const errorMessage = getUndefinedStateErrorMessage(key, action);
		throw new Error(errorMessage);
	}
	nextState[key] = nextStateForKey;
	hasChanged = hasChanged || nextStateForKey !== previousStateForKey;
}
return hasChanged ? nextState : state;
```

以上来自于 Reduxjs-[combineReducers](https://github.com/reduxjs/redux/blob/master/src/combineReducers.js)的核心实现。

combineReducers 是一个将 Reducer 分治的函数，让一个庞大数据的 Reducer 可以由多层的更小的 Reducer 组合而成。

这是 Redux 框架里的核心 API，但是他有缺点。他有非常明显的语言的局限性，如下 3 点:

1. 浅拷贝一个任意对象

```javascript
const nextState = {};
```

2. 读取字段

```javascript
const previousStateForKey = state[key];
```

3. 写入字段

```javascript
nextState[key] = nextStateForKey;
```

将上面的 3 点抽象来看：

1. State 的 clone 的能力（浅拷贝）
2. Get & Set 的能力，即为 Connector 的概念。

有了以上两点，我们才完全集成了 Redux 的所有精华，同时将它的设计更上一个通用的维度。

- 它表达了如何从一个大数据中读取小数据，同时对小数据的修改如何同步给大数据，这样的数据连接关系。
- 它是将一个集中式的 Reducer，可以由多层次多模块的小 Reducer 自动拼装的关键。
- 它大大降低了我们使用 Redux 的复杂度。我们不再关心组装过程，我们关心的核心是什么动作促使数据怎么变化。
- 它使用在配置 Dependencies 中，在配置中我们就固化了大组件和小组件之间的连接关系(数据管道)，所以在我们使用小组件的时候是不需要传入任何动态参数的。

![image.png | left | 719x375](https://cdn.nlark.com/lark/0/2018/png/82574/1545365202743-01074be7-f067-45c7-aae0-91b12cd50ae6.png)


示例代码

```dart
class DetialState {
    Profile profile;
    String message;
}

Connector<DetialState, String> messageConnector() {
    return Connector<DetialState, String>(
        get: (DetialState state) => state.message,
        set: (DetialState state, String message) => state.message = message,
    );
}
```
