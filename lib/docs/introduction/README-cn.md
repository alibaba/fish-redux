# 简介

Fish Redux 是一个基于 Redux 数据管理的组装式 flutter 应用框架， 它特别适用于构建中大型的复杂应用。

它的特点是配置式组装。
一方面我们将一个大的页面，对视图和数据层层拆解为互相独立的 Component|Adapter，上层负责组装，下层负责实现；
另一方面将 Component|Adapter 拆分为 View，Reducer，Effect 等相互独立的上下文无关函数。

所以它会非常干净，易维护，易协作。

Fish Redux 的灵感主要来自于 Redux， Elm， Dva 这样的优秀框架。而 Fish Redux 站在巨人的肩膀上，将集中，分治，复用，隔离做的更进一步。
