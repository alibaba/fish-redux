# Auto-Dispose

-   它是一个非常简易管理生命周期对象的方式。一个 auto-dispose 对象可以自我主动释放，或者在它 follow 的 托管对象释放的时候，释放。
-   在 Effect 中使用的 Context，以及 HigherEffect 中的 EffectPart，都是 auto-dispose 对象。所以我们可以方便的将自定义的需要做生命周期管理的对象托管给它们。
-   示例代码

```dart
class ItemWidgetBindingObserver extends WidgetsBindingObserver
    with AutoDispose {
  ItemWidgetBindingObserver() : super() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppConfig.flutterBinding.framesEnabled &&
        state == AppLifecycleState.resumed) {
      AppConfig.flutterBinding.performReassemble();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}

void _init(Action action, Context<ItemPageContainerState> ctx) {
    final ItemWidgetBindingObserver observer = ItemWidgetBindingObserver();
    observer.follow(ctx);
}

```
