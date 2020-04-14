# Component

组件是对视图展现和逻辑功能的封装。
面向当下，从 Redux 的视角看，我们对组件分为状态修改的功能(Reducer)和其他。
面向未来，从 UI-Automation 的视角看，我们对组件分为展现表达和其他。
结合上面两个视角，于是我们得到了，View、 Effect、Reducer 三部分，称之为组件的三要素，分别负责了组件的展示、非修改数据的行为、修改数据的操作。

我们以显式配置的方式来完成大组件所依赖的小组件、适配器的注册，这份依赖配置称之为 Dependencies。

所以有了这个公式
Component = View + Effect(可选) + Reducer(可选) + Dependencies(可选)

分治：从组件的角度
<img src="https://img.alicdn.com/tfs/TB1vqB2J4YaK1RjSZFnXXa80pXa-900-780.png" width="450px" height="390px">

集中：从 Store 的角度
<img src="https://img.alicdn.com/tfs/TB1sThMJYvpK1RjSZFqXXcXUVXa-1426-762.png" width="713px" height="381px">
