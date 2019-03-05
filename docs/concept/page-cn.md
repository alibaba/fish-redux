# Page

-   一个页面内都有且仅有一个 Store
-   Page 继承于 Component，所以它能配置所有 Component 的要素
-   Page 能配置 Middleware，用于对 Redux 做 AOP 管理
-   Page 必须配置一个初始化页面数据的初始化函数  initState
    <img src="https://img.alicdn.com/tfs/TB1ASfDJ9zqK1RjSZFHXXb3CpXa-1636-756.png" width="818px" height="378px">

-   示例代码

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
