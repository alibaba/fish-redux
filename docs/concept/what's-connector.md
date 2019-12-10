# What's connector

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

有了 以上两点，我们才完全集成了 Redux 的所有精华，同时将它的设计更上一个通用的维度。
