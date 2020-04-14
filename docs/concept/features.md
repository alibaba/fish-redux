# Features

## 直接使用 flutter 会面临的问题？

> [flutter](https://github.com/flutter/flutter) 是 google 推出的新一代跨平台渲染框架.
> 它帮助开发者解决了跨平台，高性能，富有表现力和灵活的 UI 表达，快速开发等核心问题。
> 但是如果开发大应用，还需要解决以下问题。
>
> > 1. 数据流问题
> > 2. 通信问题
> > 3. 可插拔的组件系统
> > 4. 展示和逻辑解耦
> > 5. 统一的编程模型和规范
>
> 我们可以类比 flutter 和 React，事实上在中大型应用中 React 会面临的绝大多数问题，flutter 也同样面临考验。

## 数据流问题

> 目前社区流行的数据流方案有：
> 单向数据流方案，以 Redux 为代表
> 响应式数据流方案，以 Mobx 为代表
> 其他，以 rxjs 为代表
> 那么哪一种架构最合适 flutter ？
> 我们追随了 javascript 栈绝大多数开发者的选择 - [ReduxJs](https://github.com/reduxjs/redux)
> 感谢 ReduxJs，我们是几乎 100%的还原了它在 dart 上的实现。所以我们也继承了它的优点：[Predictable],[Centralized],[Debuggable],[Flexible]。

## 通信问题

> 直接使用 flutter，在 Widgets 之间传递状态和回调，随着应用复杂度的上升，会变成是一件可怕而糟糕的事情。
> 通过 fish redux，依托于集中的 Redux 和分治的 Effect 模块，通过一个极简的 [dispatch-api](mechanism.md)，完成所有的通信的诉求。

## 可插拔的组件系统

> fish redux 通过一个配置式的 Dependencies，来完成灵活的可插拔的组件系统。同时有这一配置的存在，它解放了我们手动拼装 Reducer 的繁琐工作。
> 参考:
>
> > 1. [what's-connector](what's-connector.md)
> > 2. [connector](connector.md)
> > 3. [dependencies](dependencies.md)
> > 4. [component](component.md)
> > 5. [adapter](adapter.md)
> > 6. [what's-adapter](what's-adapter.md)

## 展示和逻辑解耦

> fish redux 从 [elm](https://guide.elm-lang.org/) 中得到了非常多的设计灵感。
> 将一个组件，拆分为相互独立的 View，Effect，Reducer 三个函数，我们优雅的解决了展示和逻辑解耦的问题。
> 通过这样的拆分，我们将 UI 的表达隔离于一个函数内，它让我们更好的面向未来，一份 UI 表达它可能来自于开发者，可能来自于深度学习框架的 UI 代码生成，可能是面向移动终端，也可能是面向浏览器。它让我们有了更多的组合的可能。
> 同时函数式的编程模型带来了更容易编写，更容易扩展，更容易测试，更容易维护等特性。

## 统一的编程模型和规范

> [directory](directory.md)
