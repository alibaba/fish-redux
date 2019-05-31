# Adapter

面向 ListView 场景的分治设计。

## 为什么有 Adapter

通常，我们对 ListView 的分治更多的局限于它展现部分，而它的逻辑部分往往是集中的。当我们试图将 ListView 内的某一局部的展现和逻辑封装在一起，我们就会遇到`Big-Cell`问题，面临性能的显著降低。这里面存在一个分治和性能上的矛盾。这个矛盾带来了复用难，可维护差，难以协作等中大型场景下的问题。

解决这个问题，有两种思路：
1. 下沉到 UI 表达层（Widgets），去实现一个高性能的 ScrollView。
2. 向上做模型抽象，得到一个逻辑上的 ScrollView，性能上的 ListView。

Fish Redux 选择了第二条更加通用的路径来解决 ListView 下的分治问题。
一个 ListView 对应了一个 Adapter，这看上去非常的像 Android 里的设计，但事实上 Fish Redux 里的 Adapter 概念走的更远。
1. 一个 Adapter 是可以由多个 Component 和 Adapter 组合而成，它有点像 flatmap & compact 的 api 的叠加。
2. Adapter 以及它的子 Adapter 的生命周期是和 ListView 是一致的。它像跨斗一般附着于 ListView 的生命周期之上。同时由于 Adapter 生命周期的提升，我们额外收获了两个非常有用的事件消息，appear 和 disappear。

注意 ⚠️ 在 Adapter 里配置的子 Component，它的生命周期和它所对应的 WidgetState 是一致的，所以它是短暂的。

Adapter 的容器有两类，用图来说明吧：

<img src="https://img.alicdn.com/tfs/TB1sXXOLQvoK1RjSZPfXXXPKFXa-1666-1104.png" width="833px" height="552px">

<img src="https://img.alicdn.com/tfs/TB10lxHLMDqK1RjSZSyXXaxEVXa-1838-1024.png" width="919px" height="512px">
