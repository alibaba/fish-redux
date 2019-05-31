# Component

Component is the encapsulation of view presentation and logic functions.
For the moment, from the perspective of Redux, we divide the component into state-manage functions (Reducers) and others.
Looking to the future, from the perspective of UI-Automation, we divide the component into presentations and others.

Combining the above two perspectives, we got the three parts of View, SideEffect, and Reducer, which are called the three factors of the component.

We use explicit configuration to complete the registration of components and adapters on which large component depend. This dependency configuration is called Dependencies.

So with this formula:
Component = View + Effect(Optional) + Reducer(Optional) + Dependencies(Optional)

Division: From the perspective of the component
<img src="https://img.alicdn.com/tfs/TB1vqB2J4YaK1RjSZFnXXa80pXa-900-780.png" width="450px" height="390px">

Concentration: From the perspective of the Store
<img src="https://img.alicdn.com/tfs/TB1sThMJYvpK1RjSZFqXXcXUVXa-1426-762.png" width="713px" height="381px">
