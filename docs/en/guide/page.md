# Page

-   One and only one store in one page
-   Page inherits from Component, so it can configure all the factors of Component.
-   Page can configure Middleware for AOP management of Redux.
-   Page must be configured with an initialization function that initializes page data initState.
    <img src="https://img.alicdn.com/tfs/TB1ASfDJ9zqK1RjSZFHXXb3CpXa-1636-756.png" width="818px" height="378px">

-   Sample Code

```dart
/// Hello World
class HelloWordPage extends Page<String, String> {
    HelloWordPage():
        super(
            initState: (String msg) => msg,
            view:(String msg, _, __) => Text('Hello ${msg}'),
        );
}

HelloWordPage().buildPage('world')
```
