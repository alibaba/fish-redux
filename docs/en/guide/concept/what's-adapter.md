# What's adapter

面向 ListView 场景的分治设计 Adapter。

> 在解答什么是 adapter 之前，我们来看下一般框架对 ListView 的分治是怎么做的。传统的手段，我们对 ListView 的分治更多的局限于它展现部分，而它的逻辑部分往往是集中的。而当我们试图将 ListView 下的某一局部的展现和逻辑封装在一起，我们就会遇到"Big-Cell"问题，面临性能的显著降低。
> 这里面存在一个分治和性能上的矛盾。这个矛盾带来了复用难，可维护差，难以协作等中大型场景下的问题。
>
> 解决这个问题，有两种思路：
>
> 1. 下沉到 UI 表达层（Widgets），去实现一个高性能的 ScrollView。
> 2. 向上做模型抽象，得到一个逻辑上的 ScrollView，性能上的 ListView。
>
> fish redux 选择了第二条更加通用的路径来解决 LisView 下的分治问题。
>
> 一个 ListView 对应了一个 Adapter，这看上去非常的像 Android 里的设计，但事实上 fish-redux 里的 Adapter 概念走的更远。
>
> 1. 一个 Adapter 是可以由多个 Component 和 Adapter 组合而成，它有点像 flatmap & compact 的 api 的叠加。
> 2. Adapter 以及它的子 Adapter 的生命周期是和 ListView 是等效的。它像跨斗一般附着于 ListView 的生命周期之上。同时由于 Adapter 生命周期的提升，我们额外收获了两个非常有用的事件消息(appear & disappear)。
>
> > 注意 ⚠️ 在 Adapter 里配置的子 Component，它的生命周期和它所对应的 WidgetState 是一致的，所以它的是短暂的。

-   Adapter 的容器有两类，用图来说明吧：

<img src="https://img.alicdn.com/tfs/TB1sXXOLQvoK1RjSZPfXXXPKFXa-1666-1104.png" width="833px" height="552px">

<img src="https://img.alicdn.com/tfs/TB10lxHLMDqK1RjSZSyXXaxEVXa-1838-1024.png" width="919px" height="512px">
