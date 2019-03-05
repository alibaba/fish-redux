# What's different with Redux ?

## They are two frameworks for solving problems at different layers.

> Redux is a framework focused on state management; Fish Redux is an application framework based on Redux for state management.

> The application framework not only solves the problem of state management, but also solves the problems of divide and conquer, communication, data drive, decoupling and so on.

## Fish Redux solves the contradiction between concentration and division.

> Redux completes the merge process from the small Reducers to the main Reducer by the user manually organizing the code;

> Fish Redux automatically completes the merge process from the small Reducers to the main Reducer by explicitly expressing the dependencies between components;

<img src="https://img.alicdn.com/tfs/TB1oeXKJYPpK1RjSZFFXXa5PpXa-1976-568.png" width="988px" height="284px">

## Fish Redux provides a simple component abstract model

> It is a combination of simple 3 functions

<img src="https://img.alicdn.com/tfs/TB1vqB2J4YaK1RjSZFnXXa80pXa-900-780.png" width="450px" height="390px">

## Fish Redux provides an abstract component model of the Adapter

> In addition to the underlying component model, Fish Redux provides an Adapter abstraction model to solve the performance problems of large cells on ListView.

> Through the upper abstraction, we get the logical ScrollView, the performance of the ListView.

<img src="https://img.alicdn.com/tfs/TB1x51VJ7PoK1RjSZKbXXX1IXXa-1852-612.png" width="617px" height="204px">
