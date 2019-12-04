# Adapter

-   我们在基础 Component 的概念外，额外增加了一种组件化的抽象 Adapter。它的目标是解决 Component 模型在 ListView 的场景下的 3 个问题
    -   1）将一个"Big-Cell"放在 ListView 里，无法享受 ListView 代码的性能优化。
    -   2）Component 无法区分 appear|disappear 和 init|dispose 事件。
    -   3）Effect 的生命周期和 View 的耦合，在 ListView 的有些场景下不符合直观的预期。
-   一个 Adapter 和 Component 几乎都是一致的，除了以下几点
    -   Component 生成一个 Widget，Adapter 生成一个 ListAdapter，ListAdapter 有能力生成一组 Widget。
        -   不具体生成 Widget，而是一个 ListAdapter，能非常大的提升页面帧率和流畅度。
    -   Effect-Lifecycle-Promote
        -   Component 的 Effect 是跟着 Widget 的生命周期走的，Adapter 的 Effect 是跟着上一级的 Widget 的生命周期走。
        -   Effect​ 提升，极大的解除了业务逻辑和视图生命的耦合，即使它的展示还未出现，的其他模块依然能通过 dispatch-api，调用它的能力。
    -   appear|disappear 的通知
        -   由于 Effect 生命周期的提升，我们就能更加精细的区分 init|dispose 和 appear|disappear。而这在 Component 的模型中是无法区分的。
    -   Reducer is long-lived, Effect is medium-lived, View is short-lived.
-   Adapter 的三种实现
    -   [DynamicFlowAdapter](dynamic-flow-adapter-cn.md)
    -   [StaticFlowAdapter](static-flow-adapter-cn.md)
    -   [CustomAdapter](custom-adapter-cn.md)
