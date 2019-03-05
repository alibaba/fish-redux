# What's different with Redux ?

## 它们是解决不同层面问题的两个框架

> Redux 是一个专注于状态管理的框架；Fish Redux 是基于 Redux 做状态管理的应用框架。

> 应用框架不仅仅要解决状态管理的问题，还要解决分治，通信，数据驱动，解耦等等问题。

## Fish Redux 解决了集中和分治的矛盾。

> Redux 通过使用者手动组织代码的形式来完成从小的 Reducer 到主 Reducer 的合并过程；

> Fish Redux 通过显式的表达组件之间的依赖关系，由框架自动完成从细力度的 Reducer 到主 Reducer 的合并过程；

<img src="https://img.alicdn.com/tfs/TB1oeXKJYPpK1RjSZFFXXa5PpXa-1976-568.png" width="988px" height="284px">

## Fish Redux 提供了一个简单的组件抽象模型

> 它通过简单的 3 个函数组合而成

<img src="https://img.alicdn.com/tfs/TB1vqB2J4YaK1RjSZFnXXa80pXa-900-780.png" width="450px" height="390px">

## Fish Redux 提供了一个 Adapter 的抽象组件模型

> 在基础的组件模型以外，Fish Redux 提供了一个 Adapter 抽象模型，用来解决在 ListView 上大 Cell 的性能问题。

> 通过上层抽象，我们得到了逻辑上的 ScrollView，性能上的 ListView。

<img src="https://img.alicdn.com/tfs/TB1x51VJ7PoK1RjSZKbXXX1IXXa-1852-612.png" width="617px" height="204px">
